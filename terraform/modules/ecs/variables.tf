variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_password_secret_arn" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
