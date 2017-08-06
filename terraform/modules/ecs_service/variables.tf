variable "cluster_name" {}

variable "name" {}

variable "task_file" {}

variable "capacity" { default = 1 }

variable "use_kms_secrets" { default = false }

variable "kms_key_id" {}
