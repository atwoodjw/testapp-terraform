resource "aws_lb" "app" {
  name            = var.name_environment
  security_groups = [aws_security_group.app_lb.id]
  subnets         = var.vpc_public_subnets
}

resource "aws_lb_target_group" "app" {
  name        = var.name_environment
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  #   default_action {
  #     type = "redirect"
  #
  #     redirect {
  #       port = "443"
  #       protocol = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }
}

# resource "aws_lb_listener" "app_https" {
#   load_balancer_arn = aws_lb.app.arn
#   port = "443"
#   protocol = "HTTPS"
#   ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn = ""
#
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }
