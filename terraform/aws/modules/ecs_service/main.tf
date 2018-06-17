data "aws_region" "selected" {
    current = true
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "service" {
    name = "${var.name}-ecs-service"
    assume_role_policy = "${data.aws_iam_policy_document.service_assume_role.json}"
}

data "aws_iam_policy_document" "service_assume_role" {
    statement {
        sid = ""
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy" "service"{
    count = "${var.use_kms_secrets}"
    name = "${var.name}-ecs"
    role = "${aws_iam_role.service.name}"
    policy = "${data.aws_iam_policy_document.service_role.json}"
}

data "aws_iam_policy_document" "service_role" {
    count = "${var.use_kms_secrets}"
    statement {
        effect = "Allow"
        actions = [
            "kms:Decrypt",
            "kms:DescribeKey"
        ]
        resources = [
            "arn:aws:kms:${data.aws_region.selected.id}:${data.aws_caller_identity.current.account_id}:key/${var.cluster_name}/${var.name}",
            "arn:aws:kms:${data.aws_region.selected.id}:${data.aws_caller_identity.current.account_id}:key/${var.kms_key_id}"
        ]
    }
}

resource "aws_kms_alias" "alias" {
    name = "alias/${var.cluster_name}/${var.name}"
    target_key_id = "${var.kms_key_id}"
}

resource "aws_ecs_service" "service" {
    name = "${var.name}"
    cluster = "${var.cluster_name}"
    task_definition = "${aws_ecs_task_definition.service.arn}"
    desired_count = "${var.capacity}"
}

resource "aws_ecs_task_definition" "service" {
    family = "${var.name}"
    container_definitions = "${data.template_file.task_definition.rendered}"
    volume = {
        name = "docker_sock",
        host_path = "/var/run/docker.sock"
    }
    volume = {
        name = "${var.name}_data",
        host_path = "/mnt/shared/${var.name}_data"
    }
    volume = {
        name = "${var.name}_secrets",
        host_path = "/mnt/shared/${var.name}_secrets"
    }
    task_role_arn = "${aws_iam_role.service.arn}"
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
