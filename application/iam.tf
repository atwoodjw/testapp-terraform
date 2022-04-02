data "aws_iam_policy_document" "app" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name_environment}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.app.json
}

# arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

resource "aws_iam_role_policy" "app" {
  name = "${var.name_environment}-task-execution-policy"
  role = aws_iam_role.app.name

  policy = jsonencode({
    Statement : [
      {
        Action : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:ecr:us-east-1:570023175774:repository/${var.name_environment}",
          "arn:aws:logs:us-east-1:570023175774:log-group:/ecs/${var.name_environment}",
          "arn:aws:logs:us-east-1:570023175774:log-group:/ecs/${var.name_environment}:log-stream:*"
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
