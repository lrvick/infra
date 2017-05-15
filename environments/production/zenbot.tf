module "zenbot_balancer" {
    source = "../../modules/route53_balancer"
    domain = "zenbot.lrvick.net"
    name = "zenbot-balancer"
    asg = "${module.zenbot_asg.id}"
    launch_topic = "${module.zenbot_asg.launch_topic}"
    terminate_topic = "${module.zenbot_asg.terminate_topic}"
}

module "zenbot_asg" {
    source = "../../modules/coreos_asg"
    name = "zenbot"
    key_name = "admin"
    subnets = "${module.vpc.public_subnets}"
    vpc_id = "${module.vpc.vpc_id}"
    kms_key_id = "ae5d10fe-dcd6-4158-9080-0966a8020239"
    cloud_config = "${data.template_file.cloud_config.rendered}"
}

data "template_file" "cloud_config" {
    template = "${file("${path.module}/files/zenbot-cloud-config.yml")}"
    vars {
        aws_region = "us-west-2"
        kms_gdax_key = "AQECAHi9QYjhyFZVrMUdobJltoPqYWJtpPywP3w+AW/9evivAQAAAH4wfAYJKoZIhvcNAQcGoG8wbQIBADBoBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDJYGPJwvBxYVFFQ8tAIBEIA7/31FWvL9UTxDsk+Q3myim4x4HOCUdFKssKGHp5uJtMcvc/eYBF2anZAerEp3BtQYXjkBHilv5edLAvo="
        kms_gdax_secret = "AQECAHi9QYjhyFZVrMUdobJltoPqYWJtpPywP3w+AW/9evivAQAAALowgbcGCSqGSIb3DQEHBqCBqTCBpgIBADCBoAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAxHCNLc44stycnFNjwCARCAc+O5Mn2eNAiqgYeAq2B4s1nVnULZAxNVFQ5iZD0mWJk3YvZaGLMYLblvDstMDA3AG4DM77GossbczMci2jYaDcTjr648s/ElfHCxTMkX3PuaDA1PZhfnWOgy0BVL3VuzBebcU5LemLZBCoelp44Z9cZsQnE="
        kms_gdax_passphrase = "AQECAHi9QYjhyFZVrMUdobJltoPqYWJtpPywP3w+AW/9evivAQAAAHgwdgYJKoZIhvcNAQcGoGkwZwIBADBiBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDO81N/FckBYGVOGHOwIBEIA1pUlmHkMAVeQYqk8zhNzC+TuYCAYrB/PHDNEaEsP3+IJRbVW1NMdQucg5Noac7lkgi22/cnA="
        decrypt_script = "${file("${path.module}/files/decrypt.sh")}"
        efs_id = "${module.zenbot_asg.efs_id}"
        domain = "zenbot.lrvick.net"
    }
}
