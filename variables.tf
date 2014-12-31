variable "stack_name" {}

# aws creds
variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}

# aws network stuff
variable "region" {
  default = "us-west-2"
}
variable "az" {}
variable "vpc" {}
variable "subnet" {}

# dns stuff
variable "route53_zone_id" {}
variable "route53_domain" {}

# coreos images
variable "coreos_amis" {
  default = {
    us-east-1 = "ami-705d3d18"
    us-west-2 = "ami-4dd4857d"
  }
}