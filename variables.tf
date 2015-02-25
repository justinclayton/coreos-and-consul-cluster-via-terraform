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
variable "lb_subnet" {}
variable "instance_subnet" {}
variable "leader_instance_size" {
  default = "m3.medium"
}
variable "follower_instance_size" {
  default = "m3.medium"
}
variable "num_leaders" {
  default = 3
}
variable "num_followers" {
  default = 7
}

# coreos images
variable "coreos_amis" {
  default = {
    us-east-1 = "ami-705d3d18"
    us-west-2 = "ami-4dd4857d"
  }
}
