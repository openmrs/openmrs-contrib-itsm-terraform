variable "image" {
  default = "87e08a17-eae2-4ce4-9051-c561d9a54bde"
}

variable "flavor" {
  default = "m1.small"
}

variable "ssh_key_file" {
  default = "./ssh/terraform-api.key"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "project_name" {
  default = "TG-ASC170002"
}

variable "external_gateway" {
  default = "865ff018-8894-40c2-99b7-d9f8701ddb0b"
}

variable "pool" {
  default = "public"
}
