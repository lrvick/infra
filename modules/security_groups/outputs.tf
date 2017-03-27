output "allow_all_internal" {
  value = "${aws_security_group.allow_all_internal.id}"
}

output "allow_all_outbound" {
  value = "${aws_security_group.allow_all_outbound.id}"
}

output "allow_all_inbound" {
  value = "${aws_security_group.allow_all_inbound.id}"
}

output "allow_all_inbound_ssh" {
  value = "${aws_security_group.allow_all_inbound_ssh.id}"
}

output "allow_all_inbound_http" {
  value = "${aws_security_group.allow_all_inbound_http.id}"
}

output "allow_all_inbound_https" {
  value = "${aws_security_group.allow_all_inbound_https.id}"
}
