output "user_password" {
  value = "${aws_iam_user_login_profile.user.encrypted_password}"
}

output "user_id" {
  value = "${aws_iam_access_key.user.id}"
}

output "user_secret" {
  value = "${aws_iam_access_key.user.encrypted_secret}"
}
