# OpenTofu/Terraform deployment of ATProto's PDS server

## Requirements
* an AWS account with CLI access creds already exported. If you have creds in hashicorp's vault, checkout providers.tf
* opentofu/terraform
* you must own a domain. It's best if it's in the AWS account in question, if not, setup the hosted zone in route53 by hand and then import the zone by zoneid with the commented out block in r53.tf

## Setup
(if you use terraform, just chang ethe tofu commands below to terraform)
`tofu init` to get setup like normal
`tofu plan` to get an idea of what changes will be made to your AWS account
`tofu apply` applys the changes

tofu/terraform will ask you for your domain name, IP you want to allow to ssh to the ec2 instance, and the ssh pubkey you want to use. You can optionally declare the admin password you want to use. If you do not set one, one will be randomly generated.
