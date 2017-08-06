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

resource "aws_route53_zone" "personal" {
    name = "lrvick.net"
    tags {
        Environment = "production"
    }
}

resource "aws_route53_record" "wildcard" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "*.lrvick.net"
    type = "A"
    ttl  = "300"
    records = ["104.207.150.22"]
}

resource "aws_route53_record" "base" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "${aws_route53_zone.personal.name}"
    type = "A"
    ttl = "300"
    records = ["104.207.150.22"]
}

resource "aws_route53_record" "mx" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "${aws_route53_zone.personal.name}"
    type = "MX"
    ttl = "300"
    records = [
        "1 aspmx.l.google.com",
        "5 alt1.aspmx.l.google.com",
        "5 alt2.aspmx.l.google.com",
        "10 alt3.aspmx.l.google.com",
        "10 alt4.aspmx.l.google.com"
    ]
}

module "vpc" {
    source = "../../modules/vpc"
    name = "production"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    azs = ["us-west-2a", "us-west-2b"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

resource "aws_key_pair" "admin" {
    key_name = "admin"
    public_key = "${file("../../files/lrvick.pub")}"
}

#module "personal-website" {
#    source = "modules/s3_cloudfront_site"
#    domain = "lrvick.net"
#}
