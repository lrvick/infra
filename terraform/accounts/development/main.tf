terraform {
    backend "s3" {
        bucket = "lrvick-development-terraform"
        key    = "state/development.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-development-terraform"
    }
}

provider "aws" {
 	region = "us-west-2"
}

module "vpc" {
    source = "../../modules/vpc"
    name = "development"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.107.0/24", "10.0.108.0/24"]
    azs = ["us-west-2a", "us-west-2b"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

resource "aws_key_pair" "admin" {
    key_name = "admin"
    public_key = "${file("../../files/lrvick.pub")}"
}
