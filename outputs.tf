output "consul_url" {
  value = "http://${var.stack_name}.${var.route53_domain}:8500/"
}

output "fleet_env" {
  value = "export FLEETCTL_TUNNEL=${var.stack_name}.${var.route53_domain}:2222\nexport FLEETCTL_STRICT_HOST_KEY_CHECKING=false"
}

# output "nodes" {
#   value = "${aws_elb.coreos_leader_elb.instances.*}"
# }