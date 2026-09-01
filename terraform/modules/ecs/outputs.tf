output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.main.repository_url
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}
