data "aws_region" "selected" {
    current = true
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs" {
    name = "${var.name}-ecs-service"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"
}

data "aws_iam_policy_document" "ecs_assume_role" {
    statement {
        sid = ""
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy" "ecs"{
    name = "${var.name}-ecs"
    role = "${aws_iam_role.ecs.name}"
    policy = "${data.aws_iam_policy_document.ecs_role.json}"
}

data "aws_iam_policy_document" "ecs_role" {
    statement {
        effect = "Allow"
        actions = [
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets"
        ]
        resources = ["*"]
    }
}

resource "aws_ecs_service" "service" {
    name = "${var.name}"
    cluster = "${var.cluster_name}"
    task_definition = "${aws_ecs_task_definition.service.arn}"
    desired_count = "${var.capacity}"
    #iam_role = "${aws_iam_role.ecs.name}"
}

resource "aws_ecs_task_definition" "service" {
    family = "${var.name}"
    container_definitions = "${data.template_file.task_definition.rendered}"
}

data "template_file" "task_definition" {
    template = "${file("${var.task_file}")}"
    vars {
        log_group_region = "${data.aws_region.selected.id}"
        log_group_name   = "${aws_cloudwatch_log_group.service.name}"
    }
}

resource "aws_cloudwatch_log_group" "service" {
    name = "${var.cluster_name}/${var.name}"
}
