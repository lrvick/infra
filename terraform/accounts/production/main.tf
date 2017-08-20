terraform {
    backend "s3" {
        bucket = "lrvick-production-terraform"
        key    = "state/production.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-production-terraform"
    }
}

provider "aws" {
 	region = "us-west-2"
}

resource "aws_iam_account_alias" "alias" {
    account_alias = "lrvick-production"
}

module "vpc" {
    source = "../../modules/vpc"
    name = "production"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.103.0/24", "10.0.104.0/24", "10.0.105.0/24"]
    azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

resource "aws_key_pair" "lrvick" {
    key_name = "lrvick"
    public_key = "${file("../../files/lrvick_ssh.pub")}"
}

#module "personal-website" {
#    source = "modules/s3_cloudfront_site"
#    domain = "lrvick.net"
#}
