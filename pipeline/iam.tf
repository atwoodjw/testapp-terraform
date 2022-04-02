data "aws_iam_policy_document" "app" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name_environment}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.app.json
}

# https://docs.aws.amazon.com/codepipeline/latest/userguide/security-iam.html#how-to-custom-role

resource "aws_iam_role_policy" "app" {
  name = "${var.name_environment}-codepipeline-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Statement : [
      {
        Action : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:codebuild:us-east-1:570023175774:project/${var.name_environment}"
        ]
      },
      {
        Action : [
          "codestar-connections:UseConnection"
        ],
        Effect : "Allow",
        Resource : [
          "${aws_codestarconnections_connection.app.arn}"
        ]
      },
      {
        Action : [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:UpdateService"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:ecs:us-east-1:570023175774:container-instance/${var.name_environment}/*",
          "arn:aws:ecs:us-east-1:570023175774:service/${var.name_environment}/app",
          "arn:aws:ecs:us-east-1:570023175774:task/${var.name_environment}/*"
        ]
      },
      {
        Action : [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ],
        Effect : "Allow",
        Resource : [
          "*"
        ]
      },
      {
        Action : [
          "iam:PassRole"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:iam::570023175774:role/${var.name_environment}-task-execution-role"
        ]
      },
      {
        Action : [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect : "Allow",
        Resource : [
          "${aws_s3_bucket.app.arn}",
          "${aws_s3_bucket.app.arn}/*"
        ]
      }
    ],
    Version : "2012-10-17"
  })
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.name_environment}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild.json
}

# https://docs.aws.amazon.com/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html#customer-managed-policies

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_environment}-codebuild-policy"
  role = aws_iam_role.codebuild.name

  policy = jsonencode({
    Statement : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:logs:us-east-1:570023175774:log-group:/codebuild/${var.name_environment}",
          "arn:aws:logs:us-east-1:570023175774:log-group:/codebuild/${var.name_environment}:log-stream:*"
        ]
      },
      {
        Action : [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect : "Allow",
        Resource : [
          "${aws_s3_bucket.app.arn}",
          "${aws_s3_bucket.app.arn}/*"
        ]
      }
    ],
    Version : "2012-10-17"
  })
}

# arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

resource "aws_iam_role_policy" "codebuild-ecr" {
  name = "${var.name_environment}-codebuild-ecr-policy"
  role = aws_iam_role.codebuild.name

  policy = jsonencode({
    Statement : [
      {
        Action : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:ListTagsForResource",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:ecr:us-east-1:570023175774:repository/${var.name_environment}"
        ]
      },
      {
        Action : [
          "ecr:GetAuthorizationToken"
        ],
        Effect : "Allow",
        Resource : [
          "*"
        ]
      }
    ],
    Version : "2012-10-17"
  })
}
