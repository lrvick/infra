variable "username" {}

variable "pgp_key" { default = "" }

variable "ssh_key" { default = "" }

variable "password_length" { default = "42" }

variable "groups" { type = "list" }
