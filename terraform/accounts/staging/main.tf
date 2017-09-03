terraform {
    backend "s3" {
        bucket = "lrvick-staging-terraform"
        key    = "state/staging.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-staging-terraform"
    }
}

provider "aws" {
 	region = "us-west-2"
}

resource "aws_iam_account_alias" "alias" {
    account_alias = "lrvick-staging"
}

resource "aws_route53_zone" "personal" {
    name = "lrvick-stg.net"
    tags {
        Environment = "staging"
    }
}

module "vpc" {
    source = "../../modules/vpc"
    name = "staging"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.105.0/24", "10.0.106.0/24"]
    azs = ["us-west-2a", "us-west-2b"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

module "personal-website" {
    source = "../../modules/s3_cloudfront_site"
    domain = "lrvick-stg.net"
}

module "k8s" {
    source = "../../modules/k8s"
    region = "${aws.region}"
    base_domain = "${aws_route_53_zone.personal.name}"
    vpc_id = "${vpc.vpc_id}"
}
