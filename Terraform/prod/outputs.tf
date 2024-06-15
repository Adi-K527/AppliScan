output "workspace" {
  value = terraform.workspace
}

output "ecr_name" {
    value = aws_ecr_repository.appliscan_ecr.name
}