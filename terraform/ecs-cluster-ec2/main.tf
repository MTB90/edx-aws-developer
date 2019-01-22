# Local variables
locals {
  module = "ecs"
  name   = "${format("%s-%s", var.tags["Project"] ,local.module)}"
}

locals {
  tags = "${merge(var.tags, map("Module", local.module, "Name", local.name))}"
}

# ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${format("%s-cluster-ec2", local.name)}"
  tags = "${local.tags}"
}

# Lanunch configuration
resource "aws_security_group" "launch_configuration_sg" {
  name = "${format("%s-launch-config-sg", local.name)}"
  tags = "${merge(var.tags, map("Name", format("%s-launch-config-sg", local.name)))}"
}

resource "aws_launch_configuration" "launch_configuration" {
  name = "${format("%s-launch-config", local.name)}"

  image_id        = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.launch_configuration_sg.id}"]
}
