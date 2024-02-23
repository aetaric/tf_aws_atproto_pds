# # Vault Provider
# provider "vault" {
#   address = var.vault_server
#   token   = var.vault_token
# }

# # import the secret mount
# import {
#   to = vault_mount.kvv2
#   id = "secret"
# }

# # Vault Secrets mount
# resource "vault_mount" "kvv2" {
#   path        = "secret"
#   type        = "kv"
#   options     = { version = "2" }
#   description = "KV Version 2 secret engine mount"
# }

# # AWS nomercy Account details
# data "vault_kv_secret_v2" "aws" {
#   mount = vault_mount.kvv2.path
#   name  = "path/to/secret"
# }

# # Configure the AWS Provider with the account details
# provider "aws" {
#   region     = "us-east-1"
#   access_key = data.vault_kv_secret_v2.aws.data["access_key"]
#   secret_key = data.vault_kv_secret_v2.aws.data["secret_key"]
# }

provider "aws" {
  region = "us-east-1"
}