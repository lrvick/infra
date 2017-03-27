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

resource "aws_cloudwatch_event_rule" "console" {
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
