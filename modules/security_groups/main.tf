resource "aws_security_group" "allow_all_internal" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all traffic within asg"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }
    egress = {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }
}

resource "aws_security_group" "allow_all_inbound_ssh" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all inbound SSH traffic"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_all_inbound_http" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all inbound HTTP traffic"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_all_inbound_https" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all inbound HTTPS traffic"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_all_outbound" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all outbound traffic"
    vpc_id = "${var.vpc_id}"
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_all_inbound" {
    name_prefix = "${var.vpc_id}-"
    description = "Allow all inbound traffic"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
