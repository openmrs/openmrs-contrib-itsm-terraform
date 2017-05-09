# state file stored in S3
terraform {
  backend "s3" {
    bucket = "openmrs-terraform-state-files"
    key    = "users.tfstate"
  }
}

# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}

resource "aws_iam_user" "burke" {
  name = "burke"
}
resource "aws_iam_user" "chagara" {
  name = "chagara"
}
resource "aws_iam_user" "cintiadr" {
  name = "cintiadr"
}
resource "aws_iam_user" "pascal" {
  name = "pascal"
}
resource "aws_iam_user" "paul" {
  name = "paul"
}
resource "aws_iam_user" "rafal" {
  name = "rafal"
}
resource "aws_iam_user" "robby" {
  name = "robby"
}
