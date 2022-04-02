resource "aws_codebuild_project" "app" {
  name         = var.name_environment
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type         = "ARM_CONTAINER"

    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/${var.name_environment}"
      stream_name = "app"
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}
