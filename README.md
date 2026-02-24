# Description
This repository is the definition of OpenMRS community infrastructure (infra-as-code).
We are using terraform to generate network infra, Openstack VMs (Jetstream), DNS and backup resources.

You can also check <https://github.com/bmamlin/jetstream-api-cli.git> to check the results in Openstack.

This repository can generate documentation for all VMs created, and it's deployed to
<https://docs.openmrs.org/infrastructure/vms.html> and <https://docs.openmrs.org/infrastructure/vms.json>

Check [Provision new machine](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Provision-new-machine) and [Guidelines for New Servers](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Guidelines-for-New-Servers) for more details on how to create machines.



# Requirements
## Credentials
Before you can use this repository, you need:
  - Jetstream credentials - check internal wiki for Jetstream access details
  - Be included in git crypt in this repository (to access secrets)
  - Follow [docs](https://docs.jetstream-cloud.org/ui/cli/auth/) to obtain your personal `openrc.sh` file. Don't use any specific role. 
### Kubernetes
If you intend to deploy Kubernetes you need to create an app credential with ‘Unrestricted (dangerous)’ application credential with all permissions, including the “loadbalancer” permission.

## Software
You need to have installed:
  - [git-crypt](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md)
  - ruby (2.0+)
  - thor (`gem install thor`)
  - `wget`
  - if you are running on mac M1/M2, ensure rosetta is installed

# Development environment setup
To install terraform, run git crypto and initial setup (needed only once after cloning repo)
```
$ ./build.rb install

# edit conf/openrc-personal and add your Jetstream 2 credentials to 
$ vi conf/openrc-personal

# verify file is not encrypted
$ cat conf/openrc

# to init terraform in all VMs (takes time)
$ ./build.rb init_all

# to init terraform in a single VM (e.g. narok)
$ ./build.rb init narok
```

To undo the changes from the previous commands:
```
$ ./build.rb clean
```

To run terraform plan (and see what changed on your stack) on a _base-network_ stack:
```
$ ./build.rb plan base-network/
```

To run terraform apply (and apply changes to a stack) on a _base-network_ stack:
```
$ ./build.rb apply base-network/
```

To see all available commands:
```
$ ./build.rb
```

Forcing a VM to be reprovisioned (and keep the data volume):
```
$ ./build.rb taint-vm <stack>
$ ./build.rb plan <stack>
$ ./build.rb apply <stack>
```

To create a new stack _test_:
```
$ ./build.rb create test
```

To create a new machine, check [Create new VM](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Provision-new-machine) docs. 


To completely destroy a VM (and its data volume):

- Edit `modules/single-machine/vm.tf` and edit `prevent_destroy = true` to `prevent_destroy = false`
- Run:
```
$ ./build.rb destroy <stack>
```
- Undo changes to `modules/single-machine/vm.tf`

To manipulate the terraform state file (e.g. maji), run:
```
$ MACHINE=jinka
$ ./build.rb terraform $MACHINE "state pull" > $MACHINE/remote_state.tfstate
$ cp $MACHINE/remote_state.tfstate $MACHINE/remote_state_backup.tfstate

Edit jinka/remote_state.tfstate:
  - Remove the first line, as it's not valid json
  - Increase the serial number
  - edit the state file as desired

$ ./build.rb terraform $MACHINE "state push remote_state.tfstate" 
```


To generate and update VM documentation:
```
$ ./build docs
$ ./build plan docs
$ ./build apply docs
```

# Run OpenStack commands

Use the embedded Jetstream2 command line interface tool to access Jetstream2 through the command line.
OpenStack commands may be issued using the "os" alias (e.g., `os server list`).

```
$ cd cli
$ ./cli.sh
```

This will invoke a docker container with the necessary settings to interact directy with Jetsteam's
OpenStack environment via the command line.

# Kubernetes
Kubernetes is deployed with OpenStack Magnum.
The cluster can be set up / updated with:
```
$ ./build.rb plan kubernetes
$ ./build.rb apply kubernetes
```
OpenStack Magnum will automatically provision Kubernetes control plane and worker nodes.

The Kubernetes dashboard is configured to be accessible at https://k8s.openmrs.org.
You can get token credentials by running:
```bash
./build.rb terraform kubernetes 'output --raw kubernetes_dashboard_token'
```
The terraform outputs kubeconfig at `kubernetes/kubeconfig`. You can use it with:
```bash
export KUBECONFIG=$(pwd)/kubernetes/kubeconfig
kubectl get nodes
```

The cluster is configured with the nginx ingress controller behind an OpenStack Load Balancer. Use the `nginx` ingress class name.

There is also cert-manager deployed to create and renew SSL certificates for nginx ingress via letsencrypt. Add the `cert-manager.io/cluster-issuer: letsencrypt` annotation on your ingress to have SSL certificate.

The cluster has the following storage classes:
- `default` for Cinder attached volumes
- `local-path` for local storage volumes

Please note that local storage is limited to worker node disk size (60GB for m3.medium), but it has the best performance.

The O3 k8s deployment is at https://o3-k8s.openmrs.org. It is the most robust deployment with MariaDB Galera, ElasticSearch, Minio and fully replicated OpenMRS backend and frontend services.

# Repository organisation
  - _build.rb_: build helper (thor) file
  - _conf/_ : configuration files and authentication files
  - _conf/template-stack_: base files used when creating new stacks
  - _conf/provisioning_: keys and helpers to run ansible when provisioning a machine. Each
  - _modules/_: terraform modules
  - _modules/single-machine_: terraform module to generate a machine, with a A DNS record.
  - _global-variables.tf_: global terraform variables symlinked on each stack
  - _base-network/_ : stack basic infrastructure (network, subnets, routers)
  - _other-stacks/_: each machine should have a directory defined in here. Each folder should be a different state/stack file.

Each stack should be more or less:
  - _main.tf_: terraform resources
  - _outputs.tf_: stack outputs (can be used by other stacks as input params)
  - _variables.tf_: terraform variables
  - _global-variables.tf_: symlink to the top level global file.

# Troubleshooting

## Could not create DNS entries
- Verify that the entry doesn't already exist in our DNS provider.

## Cannot run null_resources via SSH after first ansible run
Ansible configures and secures our SSH configuration, so root cannot SSH anymore.

Change `./global-variables` and use your username and (passphrase-less) key. Do not commit this change.



# Gotchas
  - DNS CNAME records cannot be imported by terraform, so they have to be deleted in our DNS server before using them in a stack.
  - Don't use the DNS redirect. It doesn't support HTTPS.
  - Use _/etc/ansible/facts.d/_ files to export data to ansible. If the files should be modified, you can do it manually.

# Resources needed by Terraform
Some resources are necessary to run terraform, so they were created manually:
  - S3 bucket to keep terraform state (versioned)
  - User to interact with bucket (access via bucket policy)
  - DNS domains (not defined in terraform provider)
