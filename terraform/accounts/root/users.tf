resource "aws_iam_user" "lrvick" {
  name = "lrvick"
}

resource "aws_iam_user_login_profile" "lrvick" {
  user = "${aws_iam_user.lrvick.name}",
  pgp_key = "${base64encode(file("../../files/lrvick_pgp.key"))}"
  password_reset_required = true
  password_length = 50
}

resource "aws_iam_access_key" "lrvick" {
  user    = "${aws_iam_user.lrvick.name}"
  pgp_key = "${base64encode(file("../../files/lrvick_pgp.key"))}"
}

resource "aws_iam_user_ssh_key" "lrvick" {
  username = "${aws_iam_user.lrvick.name}"
  encoding = "PEM"
  public_key = "${file("../../files/lrvick_ssh.pub")}"
}

resource "aws_key_pair" "lrvick" {
  key_name = "lrvick"
  public_key = "${file("../../files/lrvick_ssh.pub")}"
}

output "lrvick_password" {
  value = "${aws_iam_user_login_profile.lrvick.encrypted_password}"
}

output "lrvick_iam_secret" {
  value = "${aws_iam_access_key.lrvick.encrypted_secret}"
}
