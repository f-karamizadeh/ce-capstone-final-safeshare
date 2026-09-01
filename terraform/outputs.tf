output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnets" {
  value = module.networking.public_subnet_ids
}

output "private_subnets" {
  value = module.networking.private_subnet_ids
}

output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
