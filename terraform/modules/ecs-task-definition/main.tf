# Local variables
locals {
  module    = "ecs-task-definition"
  name      = "${format("%s-%s", var.tags["Project"] ,local.module)}"
  tags      = "${merge(var.tags, map("Module", local.module))}"
  log_group = "${format("%s/container/awslog", var.tags["Project"])}"
}

# Resources
resource "aws_ecs_task_definition" "task_definition" {
  family       = "${local.name}"
  network_mode = "awsvpc"

  container_definitions = <<DEF
[
  {
    "name": "${local.name}",
    "image": "${var.docker_image_uri}",
    "cpu": ${var.cpu_unit},
    "memory": ${var.memory},
    "memoryReservation": ${var.memory},
    "entryPoint": [
      "flask"
    ],
    "command": [
      "run", "--host=0.0.0.0"
    ],
    "environment": [
      {
        "name": "FLASK_APP",
        "value": "app"
      },
      {
        "name": "FLASK_RUN_PORT",
        "value": "80"
      }
    ],
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.log_group}",
        "awslogs-region": "${var.region}"
      }
    },
    "workingDirectory": "${var.workdir}",
    "healthCheck": {
      "retries": ${var.retries},
      "command": [
        "CMD-SHELL",
        "curl -f http://localhost: || exit 1"
      ],
      "timeout": ${var.timeout},
      "interval": ${var.interval},
      "startPeriod": ${var.start_period}
    }
  }
]
DEF
}

resource "aws_cloudwatch_log_group" "container_log_group" {
  name = "${local.log_group}"
  tags = "${var.tags}"
}
