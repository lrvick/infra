data "aws_region" "selected" {
    current = true
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "selected" {
    name = "${replace(var.domain, "/^.*\\.([^\\.]+)\\.([^\\.]+)$/", "$1.$2.")}"
}

resource "aws_eip" "pool" {
    vpc = true
    count = "${var.num_ips}"
}

resource "aws_route53_record" "eip" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name = "${var.domain}"
    type = "A"
    ttl = "300"
    records = ["${element(aws_eip.pool.*.public_ip,count.index)}"]
    set_identifier = "${count.index}"
        weighted_routing_policy {
        weight = 10
    }
    count = "${var.num_ips}"
}

resource "aws_route53_health_check" "eip" {
    ip_address = "${element(aws_eip.pool.*.public_ip,count.index)}"
    port = "${var.health_port}"
    type = "${var.health_type}"
    resource_path = "${var.health_path}"
    failure_threshold = "5"
    request_interval  = "30"
    tags = {
        Name = "${var.name} - EIP ${count.index}"
    }
    count = "${var.num_ips}"
}

resource "aws_cloudwatch_event_rule" "ecs_state_change" {
    name = "${var.name}-task-state"
    description = "Capture container startup for ${var.name}"
    event_pattern = <<PATTERN
{
  "source": [ "aws.ecs" ],
  "detail-type": [ "ECS Task State Change" ],
  "detail": { "clusterArn": [ "${var.cluster}" ]}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "ecs_state_change" {
    rule = "${aws_cloudwatch_event_rule.ecs_state_change.name}"
    target_id = "${var.name}-ecs_state_change"
    arn = "${aws_lambda_function.ecs_eip_attach.arn}"
}

resource "aws_lambda_permission" "cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ecs_eip_attach.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.ecs_state_change.arn}"
}

resource "aws_lambda_function" "ecs_eip_attach" {
    filename = "${data.archive_file.ecs_eip_attach.output_path}"
    source_code_hash = "${data.archive_file.ecs_eip_attach.output_base64sha256}"
    role = "${aws_iam_role.ecs_eip_attach.arn}"
    function_name = "${var.name}-ecs_eip_attach"
    handler = "index.handler"
    runtime = "python2.7"
}

data "archive_file" "ecs_eip_attach" {
    type = "zip"
    source_dir = "${path.module}/lambda/ecs_eip_attach/"
    output_path = "${path.module}/.terraform/archive/lambda_ecs_eip_attach.zip"
}

resource "aws_iam_role_policy" "ecs_eip_attach" {
    name = "${var.name}-lambda-ecs-eip-attach"
    role = "${aws_iam_role.ecs_eip_attach.id}"
    policy = "${data.aws_iam_policy_document.ecs_eip_attach_role_policy.json}"
}
data "aws_iam_policy_document" "ecs_eip_attach_role_policy" {
    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]
        resources = ["arn:aws:logs:${data.aws_region.selected.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
    }
}

resource "aws_iam_role" "ecs_eip_attach" {
    name = "${var.name}-lambda-ecs-eip-attach"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_eip_attach_role.json}"
}

data "aws_iam_policy_document" "ecs_eip_attach_role" {
    statement {
        sid = ""
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

