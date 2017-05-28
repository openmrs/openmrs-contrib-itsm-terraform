variable "image" { }

variable "pool" {
  default = "public"
}

variable "has_backup" {
  default = false
}

variable "use_ansible" {
  default = false
}

variable "flavor" { }

variable "hostname" { }

variable "project_name" { }

variable "ssh_username" { }

variable "ssh_key_file" { }

variable "domain_dns" { type = "map" }

variable "ansible_inventory" { }

variable "ansible_repo" {  }
