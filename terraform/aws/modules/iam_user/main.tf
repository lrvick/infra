resource "aws_iam_user" "user" {
  name = "${var.username}"
}

resource "aws_iam_user_login_profile" "user" {
  count = "${var.pgp_key == "" ? 0 : 1}"
  user = "${aws_iam_user.user.name}",
  pgp_key = "${base64encode(file(var.pgp_key))}"
  password_reset_required = true
  password_length = "${var.password_length}"
}

resource "aws_iam_access_key" "user" {
  count = "${var.pgp_key == "" ? 0 : 1}"
  user = "${aws_iam_user.user.name}"
  pgp_key = "${base64encode(file(var.pgp_key))}"
}

resource "aws_iam_user_ssh_key" "user" {
  count = "${var.ssh_key == "" ? 0 : 1}"
  username = "${aws_iam_user.user.name}"
  encoding = "PEM"
  public_key = "${file(var.ssh_key)}"
}

resource "aws_key_pair" "user" {
  count = "${var.ssh_key == "" ? 0 : 1}"
  key_name = "${var.username}"
  public_key = "${file(var.ssh_key)}"
}

resource "aws_iam_group_membership" "user" {
  count = "${length(var.groups)}"
  name = "${aws_iam_user.user.name}-${element(var.groups, count.index)}"
  group = "${element(var.groups, count.index)}"
  users = [ "${aws_iam_user.user.name}" ]
}
