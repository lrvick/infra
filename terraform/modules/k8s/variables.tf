variable "dns" { default = "public" }
variable "topology" { default = "public" }
variable "api_loadbalancer_type" { default = "public" }
variable "region" { default = "us-west-2" }
variable "base_domain" {}
variable "vpc_id" { default = "" }
variable "kops_version" { default = "1.7.0" }
variable "networking" { default = "flannel" }
variable "k8s_version" { default = "" }
variable "slave_zones" {
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
variable "master_zones" {
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
