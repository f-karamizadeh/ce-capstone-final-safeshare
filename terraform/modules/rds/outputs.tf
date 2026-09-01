output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "db_name" {
  value = aws_db_instance.main.db_name
}
