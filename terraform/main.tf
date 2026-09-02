module "vpc" { source = "./modules/vpc" }
module "s3" { source = "./modules/s3" }
module "dynamodb" { source = "./modules/dynamodb" }
module "eventbridge" { source = "./modules/eventbridge" }