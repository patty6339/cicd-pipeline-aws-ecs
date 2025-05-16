# This policy document defines the trust relationship allowing ECS tasks to assume this role
# by specifying the ecs-tasks.amazonaws.com service principal
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service" 
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Creates an IAM role that ECS tasks can assume, using the trust policy defined above
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "EcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

# Attaches the AWS managed policy that grants permissions needed by the ECS task execution service
# This includes permissions for pulling container images and publishing logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attaches the AWS Systems Manager policy required for ECS Exec functionality
# This allows executing commands in running containers for debugging purposes
resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ECS cluster definition
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.log_group_name
  retention_in_days = 7
}


# ECS task definition for Fargate launch type
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]


  # IAM roles for task execution and task role
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # Dependencies required before task definition can be created
  depends_on = [aws_iam_role.ecs_task_execution_role, docker_registry_image.image, aws_cloudwatch_log_group.ecs_logs]

  # Container definition with environment variables and logging configuration
  container_definitions = templatefile("${path.module}/website_taskdef.tpl", {
    container_name = var.container_name
    image          = docker_image.image.name
    log_group_name = var.log_group_name
    aws_region     = var.aws_region

  })

}



# ECS service running on Fargate
resource "aws_ecs_service" "ecs_service" {
  name                   = var.service_name
  cluster                = aws_ecs_cluster.cluster.id
  task_definition        = aws_ecs_task_definition.task_definition.arn
  desired_count          = 2
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Network configuration for the Fargate tasks
  network_configuration {
    subnets          = module.networking.private_subnets
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = var.container_name
    container_port   = 80
  }
  # Add ALB listener as dependency to ensure target group is ready
  depends_on = [
    aws_lb_target_group.alb_tg,
    aws_security_group.ecs_task_sg,
    aws_ecs_task_definition.task_definition
  ]

  # Add health check grace period to allow container time to start
  health_check_grace_period_seconds = 60

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

  tags = {
    Name = var.service_name
  }
}
