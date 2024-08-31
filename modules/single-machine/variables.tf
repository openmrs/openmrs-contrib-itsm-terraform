# [Required] VM size.
# Check https://docs.jetstream-cloud.org/general/vmsizes/ for options
variable "flavor" { }

# [Required] VM hostname. Should be unique.
# Details on the repository README.md file
variable "hostname" { }

# [Optional] Where the VM should be created.
# Values could be 'v2' only
variable "region" {
  default = "v2"
}

# [Optional] if OS should be upgraded as part of provisioning
variable "update_os" {
  default = true
}

# [Optional] if ansible facts should be generated as part of provisioning
variable "copy_ansible_facts" {
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
  type    = list
  default = []
}

# [Optional] create DNS entry for private IP
variable "has_private_dns" {
  default = false
}

# [Optional] extra security_groups to apply to VM
variable "extra_security_groups" {
  type    = list
  default = []
}

# [Optional] remove web security group
variable "allow_web" {
  default = "true"
}

# [Optional] If it should create a credentials to clone git repositories
# from github and decrypt using git-crypt
variable "leave_git_clone_creds" {
  default = false
}

# [Optional] To leave machine running (active) or powered off (shutoff)
variable "power_state" {
  default = "active"
}

######  DO NOT CHANGE variables below ######
########  Check global-variables for their values. ########

# Image for the new VM.
# Automation is only tested for Ubuntu 22.
variable "image" { }

# Jetstream project
variable "project_name" { }

# User to SSH into new VM
variable "ssh_username" { }

# Key file to SSH into new box
variable "ssh_key_file" { }

# DNS domains in our DNS provider
variable "domain_dns" { type = map }

# repository where to download ansible code
variable "ansible_repo" {  }

# Floating IP Pool
variable "pool" {
  default = "public"
}

variable "dme_apikey" {
  default = ""
}

variable "dme_secretkey" {
  default = ""
}