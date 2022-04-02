resource "aws_cloudwatch_log_group" "app" {
  name              = "/codebuild/${var.name_environment}"
  retention_in_days = 365
}
