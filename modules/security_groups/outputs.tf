output "allow_all_internal" {
  value = "${aws_security_group.allow_all_internal.id}"
}

output "allow_all_outbound" {
  value = "${aws_security_group.allow_all_outbound.id}"
}

output "allow_all_inbound" {
  value = "${aws_security_group.allow_all_inbound.id}"
}

output "allow_all_ssh" {
  value = "${aws_security_group.allow_all_ssh.id}"
}
