variable "name" {}

variable "vpc_id" {}

variable "key_name" {}

variable "subnets" { type = "list" }

variable "instances_min" { default = 1 }

variable "instances_max" { default = 1 }

variable "instances_desired" { default = 1 }

variable "instance_type" { default = "t2.nano" }
