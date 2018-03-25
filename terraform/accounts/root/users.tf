module "iam_user_lrvick" {
  source = "../../modules/iam_user"
  username = "lrvick"
  ssh_key = "../../../keys/ssh/lrvick.pub"
  pgp_key = "../../../keys/pgp/lrvick.key"
  groups = ["user", "admin", "billing"]
}
