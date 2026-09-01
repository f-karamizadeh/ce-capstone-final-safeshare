variable "project_name" {
  type    = string
  default = "safeshare"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_password_secret_arn" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
