output "vpc_id" {
  value = module.networking.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "ecr_repo_url" {
  value = module.ecs.ecr_repo_url
}
