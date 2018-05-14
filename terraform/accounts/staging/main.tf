terraform {
  required_version = "~> 0.11.7"
  backend "s3" {
    bucket = "lrvick-staging-terraform"
    key = "state/staging.tfstate"
    region = "us-west-2"
    dynamodb_table = "lrvick-staging-terraform"
    role_arn = "arn:aws:iam::686710404202:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-west-2"
  allowed_account_ids = ["686710404202"]
  assume_role {
    role_arn = "arn:aws:iam::686710404202:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-west-2"
  alias = "usw2"
  allowed_account_ids = ["686710404202"]
  assume_role {
    role_arn = "arn:aws:iam::686710404202:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "use1"
  allowed_account_ids = ["686710404202"]
  assume_role {
    role_arn = "arn:aws:iam::686710404202:role/OrganizationAccountAccessRole"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_account_alias" "alias" {
    account_alias = "lrvick-staging"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "1.30.0"
    name = "staging"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.106.0/24", "10.0.107.0/24", "10.0.108.0/24"]
    azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}
