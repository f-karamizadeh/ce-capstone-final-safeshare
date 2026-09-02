terraform {
  backend "s3" {
    bucket       = "ce-capstone-final-safeshare-tfstate-farama"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "SafeShare"
      Owner       = "farama"
      Environment = var.environment
    }
  }
}