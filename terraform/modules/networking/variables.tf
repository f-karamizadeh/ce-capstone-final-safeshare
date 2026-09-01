variable "project_name" {
  description = "Project name"
  type        = string
  default     = "safeshare"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}
