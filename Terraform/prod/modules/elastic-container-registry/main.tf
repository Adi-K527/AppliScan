resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_name
}

resource "null_resource" "docker_operations" {
  provisioner "local-exec" {
    command = <<-EOT
      docker pull alpine
      docker tag alpine ${aws_ecr_repository.ecr_repo.repository_url}:latest
      docker push ${aws_ecr_repository.ecr_repo.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.ecr_repo]
}