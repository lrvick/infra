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
    name = "ci"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    azs = ["us-west-2a", "us-west-2b"]
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
}

module "drone_balancer" {
    source = "../../modules/route53_balancer"
    domain = "ci.lrvick.net"
    name = "droneci-balancer"
    asg = "${module.drone_asg.id}"
    launch_topic = "${module.drone_asg.launch_topic}"
    terminate_topic = "${module.drone_asg.terminate_topic}"
}

module "drone_asg" {
    source = "../../modules/coreos_asg"
    name = "drone"
    key_name = "admin"
    subnets = "${module.vpc.public_subnets}"
    vpc_id = "${module.vpc.vpc_id}"
    kms_key_id = "5a5fecb6-77d2-42e9-82f1-884dbee74c76"
    cloud_config = "${data.template_file.cloud_config.rendered}"
}

data "template_file" "cloud_config" {
    template = "${file("${path.module}/files/drone-cloud-config.yml")}"
    vars {
        aws_region = "us-west-2"
        kms_drone_github_client = "AQECAHjxFVv28s35RRShRB2bYo11qtmAuBRaqhGRrhmkdMTRYgAAAHIwcAYJKoZIhvcNAQcGoGMwYQIBADBcBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDCxWZFvY5VddfEyz6QIBEIAv5O5Vg6W6tmQaNYW3jrbX71PMf6ZrzzwvtBdakQLGk0VfDpqCDvphWzEXMb9vd2o="
        kms_drone_github_secret = "AQECAHjxFVv28s35RRShRB2bYo11qtmAuBRaqhGRrhmkdMTRYgAAAIcwgYQGCSqGSIb3DQEHBqB3MHUCAQAwcAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAxq8f21DDHmNkXpG84CARCAQ5w5DUqkRTM65cS+Tb2MQZ5/gpLE8XCZ+lLUc2r8aoO11VoX+kIj1yOs5FRsXcWiQkTre5gA7fUtfG6r7StBbKIxLHM="
        kms_drone_secret = "AQECAHjxFVv28s35RRShRB2bYo11qtmAuBRaqhGRrhmkdMTRYgAAAKQwgaEGCSqGSIb3DQEHBqCBkzCBkAIBADCBigYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAwIb1iU4qYmJMUY3yUCARCAXQHkjL1W7Vikyi4VX3R4h/pm+lX14gQBzSSuX7pxbxlwMxt1ZdpeisjbbpUC6ccK/o3IAXKgj9D7DY0Yt+lQ8ph4/j8cjOfUlQI/POgrEqdV+P0LZdppE0UwSWJsnA=="
        drone_orgs = ""
        decrypt_script = "${file("${path.module}/files/decrypt.sh")}"
        efs_id = "${module.drone_asg.efs_id}"
        domain = "ci.lrvick.net"
        drone_admins = "lrvick"
    }
}
