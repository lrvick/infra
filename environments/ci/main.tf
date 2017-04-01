terraform {
    backend "s3" {
        bucket = "lrvick-ci-terraform"
        key = "state/ci.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-ci-terraform"
    }
}

provider "aws" {
    region = "us-west-2"
}

module "vpc" {
    source = "../../modules/vpc"
    name = "production"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.105.0/24", "10.0.106.0/24"]
    azs = ["us-west-2a", "us-west-2b"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

module "droneci_balancer" {
    source = "../../modules/route53_balancer"
    domain = "ci.lrvick.net"
    name = "${module.droneci_cluster.name}"
    asg = "${module.droneci_cluster.asg_id}"
}

module "droneci_cluster" {
    source = "../../modules/ecs_cluster"
    name = "droneci"
    key_name = "admin"
    subnets = "${module.vpc.public_subnets}"
    vpc_id = "${module.vpc.vpc_id}"
}

module "droneci_service" {
    source = "../../modules/ecs_service"
    name = "droneci"
    cluster_name = "${module.droneci_cluster.name}"
    task_file = "${path.root}/tasks/nginx.json"
}
