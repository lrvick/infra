resource "aws_route53_record" "chat" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "chat.${aws_route53_zone.personal.name}"
    type = "A"
    ttl = "300"
    records = ["${aws_instance.chat.public_ip}"]
}

data "aws_ami" "debian" {
    most_recent = true
    filter {
        name   = "name"
        values = ["debian-stretch-hvm-x86_64-gp2-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["379101102735"]
}

module "chat_security_group" {
    source = "../../modules/security_group"
    vpc_id = "${module.vpc.vpc_id}"
    name = "chat"
    all_internal = true
    all_outbound = true
    all_inbound_ssh = true
    all_inbound_custom = [ "8000" ]
}

resource "aws_ebs_volume" "chat" {
    availability_zone = "us-west-2a"
    size = 30
    tags {
        Name = "chat_home"
    }
}

resource "aws_volume_attachment" "chat" {
    device_name = "/dev/sdh"
    volume_id = "${aws_ebs_volume.chat.id}"
    instance_id = "${aws_instance.chat.id}"
}

resource "aws_instance" "chat" {
    ami = "${data.aws_ami.debian.id}"
    availability_zone = "us-west-2a"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.lrvick.key_name}"
    monitoring = true
    vpc_security_group_ids = [ "${module.chat_security_group.id}" ]
    subnet_id = "${module.vpc.public_subnets[0]}"
    tags {
        Name = "chat"
    }
}
