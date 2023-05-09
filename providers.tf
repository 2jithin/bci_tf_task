provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.0.1"
    }
    aws = {
      version = "= 3.66.0"
    }
  }
}

provider "random" {
  
}

resource "random_string" "admin_passwords" {
  count            = var.instance_count
  length           = 16
  special          = true
  override_special = "_%@"
  upper            = true
  lower            = true
  keepers = {
    timestamp = timestamp()
  }
}