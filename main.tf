provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

resource "aws_autoscaling_group" "coreos_leader_autoscale" {
  name                 = "leader_autoscale"
  load_balancers       = ["${aws_elb.coreos_leader_elb.id}"]
  vpc_zone_identifier  = ["${var.subnet}"]
  availability_zones   = ["${var.az}"]
  min_size             = 3
  max_size             = 5
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.coreos_leader_launchconfig.name}"
}

resource "aws_launch_configuration" "coreos_leader_launchconfig" {
  name            = "leader_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "m3.medium"
  security_groups = ["${aws_security_group.coreos_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("leader-cloud-config.yml")}"
}

resource "aws_autoscaling_group" "coreos_follower_autoscale" {
  vpc_zone_identifier  = ["${var.subnet}"]
  availability_zones   = ["${var.az}"]
  name                 = "follower_autoscale"
  min_size             = 1
  max_size             = 95
  desired_capacity     = 7
  launch_configuration = "${aws_launch_configuration.coreos_follower_launchconfig.name}"
}

resource "aws_launch_configuration" "coreos_follower_launchconfig" {
  name            = "follower_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "m3.medium"
  security_groups = ["${aws_security_group.coreos_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("follower-cloud-config.yml")}"
}

resource "aws_security_group" "coreos_securitygroup" {
  name          = "coreos_securitygroup"
  description   = "allow a bunch of stuff"
  vpc_id        = "${var.vpc}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "coreos_leader_elb" {
  name                 = "coreos-leader-elb"
  security_groups      = ["${aws_security_group.coreos_securitygroup.id}"]
  internal             = true
  subnets              = ["${var.subnet}"]

  listener {
    lb_port            = 4001
    instance_port      = 4001
    lb_protocol        = "http"
    instance_protocol  = "http"
  }

  listener {
    lb_port            = 8500
    instance_port      = 8500
    lb_protocol        = "http"
    instance_protocol  = "http"
  }

  listener {
    lb_port            = 2222
    instance_port      = 22
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }

  health_check {
    target              = "HTTP:4001/version"
    healthy_threshold   = 4
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

}

resource "aws_route53_record" "elb_dns" {
  name = "${var.stack_name}.${var.route53_domain}"
  records = ["${aws_elb.coreos_leader_elb.dns_name}"]
  zone_id = "${var.route53_zone_id}"
  type = "CNAME"
  ttl = 60
}