# ----------------------------------------------------------------------------------------------------------------------
# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
# ----------------------------------------------------------------------------------------------------------------------

variable "master_flavor" {
  default = "m3.small"
}

variable "master_count" {
  default = 3
}

variable "flavor" {
  default = "m3.medium"
}

variable "node_count" {
  default = 4
}

variable "max_node_count" {
  default = 8
}

variable "docker_volume_size" {
  default = "20"
}

# [Required] VM hostname. Should be unique.
# Details on the repository README.md file
variable "hostname" {
  default = "k8s"
}

# [Optional] extra CNAMES to create on DNS
variable "dns_cnames" {
  type    = list(any)
  default = ["o3-k8s"]
}