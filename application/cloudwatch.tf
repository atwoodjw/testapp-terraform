resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name}/${var.environment}"
  retention_in_days = 365
}
