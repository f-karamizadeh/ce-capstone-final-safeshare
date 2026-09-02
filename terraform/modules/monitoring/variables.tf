variable "environment" {
  type    = string
  default = "dev"
}

variable "cert_arn" {
  type = string
}

variable "sns_email" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}