resource "aws_ecr_repository" "app" {
  name = var.name_environment

  image_scanning_configuration {
    scan_on_push = true
  }
}
