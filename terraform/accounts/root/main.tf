terraform {
    backend "s3" {
        bucket = "lrvick-root-terraform"
        key    = "state/root.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-root-terraform"
    }
}

provider "aws" {
 	region = "us-west-2"
}

resource "aws_iam_account_password_policy" "strict" {
    allow_users_to_change_password = true
    password_reuse_prevention = 24
    hard_expiry = false
    minimum_password_length = 40 # > 256 bits of entropy
    require_lowercase_characters = true
    require_uppercase_characters = true
    require_numbers = true
    require_symbols = true
}
