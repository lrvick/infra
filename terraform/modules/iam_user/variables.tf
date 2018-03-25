variable "username" {}

variable "pgp_key" { default = "" }

variable "ssh_key" { default = "" }

variable "groups" { type = "list" }
