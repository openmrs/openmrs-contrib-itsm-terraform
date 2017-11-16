# [Required] VM size.
# Check https://iujetstream.atlassian.net/wiki/x/G4AKAQ for options
variable "flavor" { }

# [Optional] Where the VM should be created.
# Values could be 'ui' or 'tacc'
variable "region" {
  default = "tacc"
}

# [Required] VM hostname. Should be unique.
# Details on the repository README.md file
variable "hostname" { }

# [Optional] if OS should be upgraded as part of provisioning
variable "update_os" {
  default = true
}

# [Optional] if ansible should be part of provisioning
variable "use_ansible" {
  default = false
}

# [Optional] ansible inventory file to use
variable "ansible_inventory" {
  default = "production"
}

# [Optional] Create data volume (extra disk)
# If applications generate non-ephemeral data,
# it should have an external volume for the app data.
# It will be mounted in /data
variable "has_data_volume" {
  default = false
}

# [Optional] size of data volume
variable "data_volume_size" {
  default = 10
}

# [Optional] if backup user should be created for this VM
variable "has_backup" {
  default = false
}

# [Optional] extra CNAMES to create on DNS
variable "dns_cnames" {
  type    = "list"
  default = []
}

# [Optional] extra security_groups to apply to VM
variable "extra_security_groups" {
  type    = "list"
  default = []
}



######  DO NOT CHANGE variables below ######
########  Check global-variables for their values. ########

# Image for the new VM.
# Automation is only tested for Ubuntu 16.
variable "image" { }

# Jetstream project
variable "project_name" { }

# User to SSH into new VM
variable "ssh_username" { }

# Key file to SSH into new box
variable "ssh_key_file" { }

# DNS domains in our DNS provider
variable "domain_dns" { type = "map" }

# repository where to download ansible code
variable "ansible_repo" {  }

# Floating IP Pool
variable "pool" {
  default = "public"
}
