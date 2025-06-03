variable "bucket_name" {
  default = "openmrs-dev-resources"
}

# ----------------------------------------------------------------
# created manually on AWS console in us-east-1 
# to avoid the whole chickens and eggs of certificates and terraform
# Ensure the manually created certs are checked via DNS
# ----------------------------------------------------------------

variable "certificate_arn" {
  default = "arn:aws:acm:us-east-1:525453398140:certificate/252df87b-b832-46e1-98df-fed5266c9a8b"
}


variable "dev3_certificate_arn" {
  default = "arn:aws:acm:us-east-1:525453398140:certificate/683f9cab-cb4e-4524-b46e-5f9463cc2a03"
}


variable "dev3_machine" {
  #  Jetstream server domain (or IP + port if behind a reverse proxy)
  default = "dimtu.openmrs.org"
}