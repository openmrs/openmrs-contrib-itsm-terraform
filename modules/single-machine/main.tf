# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config = {
        bucket = "openmrs-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}


provider "dme" {
    version = "0.1.3"
    api_key    = var.dme_apikey
    secret_key = var.dme_secretkey
}

provider "aws" {
    version = "3.57.0"
    max_retries = 100
}

provider "template" {
    version = "2.2"
}

provider "null" {
    version = "3.0.0"
}