# Create an Application Load Balancer (ALB) for the e-commerce application
# This ALB is internet-facing (external) and deployed across 2 public subnets
resource "aws_lb" "alb" {
  name                       = "e-commerce-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
  enable_deletion_protection = false
  depends_on                 = [module.networking, aws_security_group.alb_sg]

  tags = {
    Name = "e-commerce-alb"
  }
}

# Create a target group for the ALB that will route traffic to ECS tasks
# Uses IP target type since ECS tasks have their own IPs
# Health check configured to verify application health every 5 minutes
resource "aws_lb_target_group" "alb_tg" {
  name        = "e-commerce-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
  depends_on = [aws_lb.alb]

  lifecycle {
    #create_before_destroy = true
  }
}

# Create a second target group for blue/green deployment
resource "aws_lb_target_group" "alb_tg_blue" {
  name        = "e-commerce-tg-blue"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  depends_on = [aws_lb.alb]

  lifecycle {
    #create_before_destroy = true
  }
}



# Create HTTP listener on port 80 that redirects all traffic to HTTPS
# Implements security best practice of forcing HTTPS
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create HTTPS listener on port 443 that forwards traffic to target group
# Uses TLS certificate from ACM and modern security policy
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  depends_on = [aws_acm_certificate.acm_certificate]
}

