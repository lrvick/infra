resource "aws_iam_user" "lrvick" {
  name = "lrvick"
}

resource "aws_iam_user_login_profile" "lrvick" {
  user = "${aws_iam_user.lrvick.name}",
  pgp_key = "${file("../../files/lrvick.asc")}"
  password_reset_required = true
  password_length = 50
}

resource "aws_iam_user_ssh_key" "lrvick" {
  username = "${aws_iam_user.lrvick.name}"
  encoding = "PEM"
  public_key = "${file("../../files/lrvick.pub")}"
}

resource "aws_key_pair" "lrvick" {
  key_name = "lrvick"
  public_key = "${file("../../files/lrvick.pub")}"
}

output "lrvick_password" {
  value = "${aws_iam_user_login_profile.lrvick.encrypted_password}"
}
