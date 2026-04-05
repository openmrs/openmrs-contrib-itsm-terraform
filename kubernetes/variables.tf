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

# Backup / Restore
variable "velero_backup_bucket" {
  description = "S3 bucket name for Velero backups (DB, ES, volumes)"
  default     = "openmrs-k8s-velero-backups"
}

variable "velero_backup_schedule" {
  description = "Cron schedule for automated backups"
  default     = "0 2 * * *"   # every day at 02:00 UTC
}

variable "velero_backup_ttl" {
  description = "How long to keep backups before expiry"
  default     = "720h"   # 30 days
}

variable "velero_aws_region" {
  description = "AWS region of the S3 backup bucket"
  default     = "us-east-1"
}

variable "velero_aws_access_key" {
  description = "AWS access key ID for Velero backup S3 bucket"
  default     = ""
  sensitive   = true
}

variable "velero_aws_secret_key" {
  description = "AWS secret access key for Velero backup S3 bucket"
  default     = ""
  sensitive   = true
}
