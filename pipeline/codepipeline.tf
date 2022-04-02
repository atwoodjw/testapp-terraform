locals {
  branch_names = {
    dev  = "develop"
    prod = "main"
  }

  branch_name = lookup(local.branch_names, var.environment)
}

resource "aws_codepipeline" "app" {
  name     = var.name_environment
  role_arn = aws_iam_role.app.arn

  artifact_store {
    location = aws_s3_bucket.app.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.app.arn
        FullRepositoryId = "atwoodjw/testapp-node"
        BranchName       = local.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.name_environment
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.name_environment
        ServiceName = "app"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "app" {
  name          = var.name_environment
  provider_type = "GitHub"
}
