output "name" {
    value = "${var.name}"
}

output "id" {
    value = "${aws_ecs_cluster.cluster.id}"
}

output "asg_id" {
    value = "${aws_autoscaling_group.cluster.id}"
}

output "instances_max" {
    value = "${var.instances_max}"
}
output "instances_min" {
    value = "${var.instances_min}"
}
