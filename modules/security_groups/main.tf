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

resource "aws_security_group" "allow_all_ssh" {
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
