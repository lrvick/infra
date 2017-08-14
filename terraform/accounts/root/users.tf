resource "aws_iam_user" "lrvick" {
  name = "lrvick"
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
