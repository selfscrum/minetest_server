terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.13"
}

variable "access_token" {}
variable "env_name"  { }
variable "env_stage" { }
variable "location" { }
variable "system_function" {}
variable "server_image" {}
variable "server_type" {}
variable "keyname" {} 
variable "network_zone" {}
provider "hcloud" {
  token = var.access_token
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE WIREGUARD SERVER
# ---------------------------------------------------------------------------------------------------------------------

module "minestest_server" {
  source = "./modules/minetest_server"
  cluster_name      = format("%s-%s-server",var.env_stage, var.env_name)
  image             = var.server_image
  server_type       = var.server_type
  location          = var.location
  labels            = {
                      "Name"   = var.env_name
                      "Stage"  = var.env_stage
  }
  ssh_key           = var.keyname
  user_data         = templatefile (
# ---------------------------------------------------------------------------------------------------------------------
# THE MULTIPART/MIXED USER DATA SCRIPT THAT WILL RUN ON THE SERVER INSTANCE WHEN IT'S BOOTING
# ---------------------------------------------------------------------------------------------------------------------
                      "${path.module}/user-data-server.mm",
                        {
                        hcloud_token             = var.access_token
                        }
                      )
}


