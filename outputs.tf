output "consul_url" {
  value = "http://${aws_elb.coreos_leader_elb.dns_name}:8500/"
}

output "fleet_env" {
  value = "export FLEETCTL_TUNNEL=${aws_elb.coreos_leader_elb.dns_name}:2222\nexport FLEETCTL_STRICT_HOST_KEY_CHECKING=false"
}
