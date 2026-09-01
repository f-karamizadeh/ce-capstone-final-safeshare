# Root Main - مرحله 3+4+5+6+7

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.networking.private_subnet_ids
  db_password        = var.db_password
}

module "ecs" {
  source = "./modules/ecs"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  alb_sg_id              = module.alb.alb_sg_id
  target_group_arn       = module.alb.target_group_arn
  alb_listener_arn       = module.alb.alb_listener_arn
  s3_bucket_name         = module.s3.s3_bucket_name
  s3_bucket_arn          = module.s3.s3_bucket_arn
  db_name                = module.rds.db_name
  db_password_secret_arn = var.db_password_secret_arn
  aws_region             = var.aws_region
}
