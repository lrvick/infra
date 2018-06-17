terraform {
  required_version = "~> 0.11.7"
  backend "s3" {
    bucket = "lrvick-production-terraform"
    key = "state/production.tfstate"
    region = "us-west-2"
    dynamodb_table = "lrvick-production-terraform"
    role_arn = "arn:aws:iam::150259197776:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-west-2"
  allowed_account_ids = ["150259197776"]
  assume_role {
    role_arn = "arn:aws:iam::150259197776:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-west-2"
  alias = "usw2"
  allowed_account_ids = ["150259197776"]
  assume_role {
    role_arn = "arn:aws:iam::150259197776:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "use1"
  allowed_account_ids = ["150259197776"]
  assume_role {
    role_arn = "arn:aws:iam::150259197776:role/OrganizationAccountAccessRole"
  }
}

resource "aws_iam_account_alias" "alias" {
    account_alias = "lrvick-production"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "1.30.0"
    name = "production"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.103.0/24", "10.0.104.0/24", "10.0.105.0/24"]
    azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

resource "aws_key_pair" "lrvick" {
    key_name = "lrvick"
    public_key = "${file("../../../keys/ssh/lrvick.pub")}"
}

module "personal-website" {
    source = "../../modules/s3_cloudfront_site"
    domain = "lrvick.net"
}
