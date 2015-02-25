provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

resource "aws_autoscaling_group" "coreos_leader_autoscale" {
  name                 = "${var.stack_name}_leader_autoscale"
  load_balancers       = ["${aws_elb.coreos_leader_elb.id}"]
  vpc_zone_identifier  = ["${var.instance_subnet}"]
  availability_zones   = ["${var.az}"]
  min_size             = 3
  max_size             = 5
  desired_capacity     = "${var.num_leaders}"
  launch_configuration = "${aws_launch_configuration.coreos_leader_launchconfig.name}"
}

resource "aws_launch_configuration" "coreos_leader_launchconfig" {
  name            = "${var.stack_name}_leader_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.leader_instance_size}"
  security_groups = ["${aws_security_group.coreos_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("leader-cloud-config.yml")}"
}

resource "aws_autoscaling_group" "coreos_follower_autoscale" {
  vpc_zone_identifier  = ["${var.instance_subnet}"]
  availability_zones   = ["${var.az}"]
  name                 = "${var.stack_name}_follower_autoscale"
  min_size             = 0
  max_size             = 95
  desired_capacity     = "${var.num_followers}"
  launch_configuration = "${aws_launch_configuration.coreos_follower_launchconfig.name}"
}

resource "aws_launch_configuration" "coreos_follower_launchconfig" {
  name            = "${var.stack_name}_follower_config"
  image_id        = "${lookup(var.coreos_amis, var.region)}"
  instance_type   = "${var.follower_instance_size}"
  security_groups = ["${aws_security_group.coreos_securitygroup.id}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("follower-cloud-config.yml")}"
}

resource "aws_security_group" "coreos_securitygroup" {
  name          = "${var.stack_name}_coreos_securitygroup"
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
  name                 = "${var.stack_name}-coreos-leader-elb"
  security_groups      = ["${aws_security_group.coreos_securitygroup.id}"]
  internal             = false
  subnets              = ["${var.lb_subnet}"]

  listener {
    lb_port            = 4001
    instance_port      = 4001
    lb_protocol        = "http"
    instance_protocol  = "http"
  }

  listener {
    lb_port            = 8400
    instance_port      = 8400
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
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
