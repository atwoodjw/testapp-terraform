// https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/3.5.0

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3.5.0"

  name = var.name_environment

  container_insights = true

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_environment}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  container_definitions = jsonencode([
    {
      name      = var.name_environment
      image     = "containous/whoami:latest"
      cpu       = var.ecs_cpu
      memory    = var.ecs_memory
      essential = true
      portMappings = [
        {
          containerPort = 80
        }
      ]
      logConfiguration = {
        logDriver : "awslogs"
        options : {
          "awslogs-region" : "us-east-1"
          "awslogs-group" : "/ecs/${var.name_environment}"
          "awslogs-stream-prefix" : "app"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.app.arn
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.name_environment
    container_port   = "80"
  }

  network_configuration {
    subnets         = var.vpc_private_subnets
    security_groups = [aws_security_group.app_ecs.id]
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
