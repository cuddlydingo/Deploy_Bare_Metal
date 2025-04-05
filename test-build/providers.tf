terraform {

  # backend "s3" {
  #   region = "us-east-1"
  # }
  # required version of terraform for local provider
  # required_version = "~>1.2"

  required_providers {

    infoblox = {
      source  = "infobloxopen/infoblox"
      version = "2.7.0"
    }

    equinix = {
      source  = "equinix/equinix"
      version = "2.3.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.0"
    }

    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.8.3"
    }
  }
}

provider "equinix" {
  auth_token = var.auth_token
}

provider "vsphere" {
  user                 = var.vcenter_user_eqxloc3
  password             = var.vcenter_pw_eqxloc3
  vsphere_server       = "vcenter_fqdn"
  allow_unverified_ssl = true
}

provider "infoblox" {
  server   = "infoblox_ipv4"
  username = var.INFOBLOX_USERNAME
  password = var.INFOBLOX_PASSWORD
  sslmode  = false
}

# provider "aws" {
#   region     = "us-east-1"
#   access_key = var.AWS_ACCESS_KEY_ID
#   secret_key = var.AWS_SECRET_ACCESS_KEY
# }
