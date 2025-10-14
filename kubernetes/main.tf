# ----------------------------------------------------------------------------------------------------------------------
# state file stored in S3
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "kubernetes.tfstate"
  }
}

locals {
  manifests_local_path_storage = sort(fileset("${path.module}/manifests/local_path_storage", "*.yaml"))
}

resource "openstack_containerinfra_cluster_v1" "kubernetes" {
  name                = "${var.project_name}-k8s"
  cluster_template_id = "2d56f33a-713c-488a-b65f-47b625d832cd" # kubernetes-1-30-jammy, the latest version that got created
  master_count        = var.master_count
  master_flavor       = var.master_flavor
  node_count          = var.node_count
  flavor              = var.flavor
  docker_volume_size  = var.docker_volume_size
  fixed_network       = "auto_allocated_network" # Needed for cluster creation to work
  keypair             = "${var.project_name}-terraform-key"
  master_lb_enabled   = true
  floating_ip_enabled = false # Do not expose nodes publicly
  labels = {
    "auto_healing_enabled": "true"
    "auto_scaling_enabled": "true"
    "min_node_count": var.node_count
    "max_node_count": var.max_node_count
    "master_lb_floating_ip_enabled": "false" # Do not expose control plane nodes publicly
    "kube_dashboard_enabled": "false" # We will deploy the latest version with helm
  }
}

provider "kubernetes" {
  host                   = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.host
  cluster_ca_certificate = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.cluster_ca_certificate
  client_certificate     = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.client_certificate
  client_key             = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.client_key
}

provider "helm" {
  kubernetes = {
    host                   = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.host
    cluster_ca_certificate = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.cluster_ca_certificate
    client_certificate     = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.client_certificate
    client_key             = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.client_key
  }
}

resource "local_sensitive_file" "kubeconfig_file" {
  content = openstack_containerinfra_cluster_v1.kubernetes.kubeconfig.raw_config
  filename = "${path.module}/kubeconfig"
}

resource "helm_release" "ingress-nginx" {
  depends_on = [openstack_containerinfra_cluster_v1.kubernetes]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.13.3"
  namespace  = "ingress-nginx"
  create_namespace = true
}

# It is a workaround to get automatically created fip for ingress nginx load-balancer to assigning DNS name.
data "openstack_networking_floatingip_v2" "fip_lb" {
  description = "Floating IP for Kubernetes external service ingress-nginx/ingress-nginx-controller from cluster ${openstack_containerinfra_cluster_v1.kubernetes.stack_id}"
}

resource "dme_dns_record" "hostname" {
  domain_id = var.domain_dns["openmrs.org"]
  name      = var.hostname
  type      = "A"
  value     = data.openstack_networking_floatingip_v2.fip_lb.address
  ttl       = 300
}

resource "dme_dns_record" "cnames" {
  count     = length(var.dns_cnames)
  domain_id = var.domain_dns["openmrs.org"]
  name      = element(var.dns_cnames, count.index)
  type      = "CNAME"
  value     = var.hostname
  ttl       = 300
}

resource "helm_release" "cert-manager" {
  depends_on = [openstack_containerinfra_cluster_v1.kubernetes]

  name = "cert-manager"
  repository = "oci://quay.io/jetstack/charts/"
  chart = "cert-manager"
  version = "1.19.0"
  namespace = "cert-manager"
  create_namespace = true

  set = [{
    name = "crds.enabled"
    value = "true"
  }]
}

data "local_file" "https_cluster_issuer_yaml" {
  filename = "${path.module}/manifests/https_cluster_issuer.yaml"
}

resource "kubernetes_manifest" "https_cluster_issuer" {
  depends_on = [helm_release.cert-manager]

  manifest = yamldecode(data.local_file.https_cluster_issuer_yaml.content)
}

resource "kubernetes_manifest" "local_path_storage" {
  depends_on = [openstack_containerinfra_cluster_v1.kubernetes]

  for_each = { for f in local.manifests_local_path_storage : f => f }
  manifest = yamldecode(file("${path.module}/manifests/local_path_storage/${each.key}"))
}

resource "helm_release" "kubernetes-dashboard" {
  depends_on = [openstack_containerinfra_cluster_v1.kubernetes]

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  version    = "7.13.0"
  namespace  = "kubernetes-dashboard-new"
  create_namespace = true

  set = [
    {
      name  = "app.ingress.enabled"
      value = "true"
    },
    {
      name  = "app.ingress.ingressClassName"
      value = "nginx"
    },
    {
      name  = "app.ingress.hosts[0]"
      value = "${var.hostname}.openmrs.org"
    },
    {
      name  = "app.ingress.issuer.scope"
      value = "cluster"
    },
    {
      name  = "app.ingress.issuer.name"
      value = "letsencrypt"
    }
  ]
}

resource "kubernetes_service_account" "kubernetes-dashboard" {
  metadata {
    name      = "admin-user"
    namespace = helm_release.kubernetes-dashboard.namespace
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes-dashboard" {
  depends_on  = [kubernetes_service_account.kubernetes-dashboard]
  metadata {
    name      = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = helm_release.kubernetes-dashboard.namespace
  }
}

# You can fetch kubernetes-dashboard token by running ./build.rb terraform kubernetes 'output --raw kubernetes_dashboard_token'
resource "kubernetes_secret" "kubernetes-dashboard" {
  depends_on = [kubernetes_service_account.kubernetes-dashboard]
  metadata {
    name = "admin-user"
    namespace = helm_release.kubernetes-dashboard.namespace
    annotations = {
      "kubernetes.io/service-account.name" = "admin-user"
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "helm_release" "o3" {
  depends_on = [openstack_containerinfra_cluster_v1.kubernetes]

  name = "o3"
  repository = "oci://ghcr.io/openmrs"
  chart = "openmrs"
  version = "1.1.0"
  namespace = "o3"
  create_namespace = true

  values = [file("${path.module}/o3-values.key")]
}