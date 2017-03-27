variable "domain" {}
variable "name" {}
variable "asg" {}
variable "cluster" {}
variable "health_type" { default = "HTTP" }
variable "health_port" { default = "443" }
variable "health_path" { default = "/" }
variable "num_ips" {}
