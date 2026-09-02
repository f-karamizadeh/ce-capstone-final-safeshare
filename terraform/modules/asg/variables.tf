variable "private_subnets" { type = list(string) }
variable "tg_arn" { type = string }
variable "instance_profile" { type = string }
variable "tags" { type = map(string) }