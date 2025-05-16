# Create VPC using terraform-aws-modules/vpc/aws module
module "networking" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  # VPC configuration
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_task_sg" {
  name        = "e-commerce-ecs-task-sg"
  description = "Security group .for ECS tasks through ALB"
  vpc_id      = module.networking.vpc_id

  # Allow inbound HTTP traffic from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow inbound SSH access from ALB
  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "e-commerce-alb-sg"
  description = "enable http/https access on port 80 and 443 respectively"
  vpc_id      = module.networking.vpc_id


  # Allow inbound HTTP traffic from anywhere
  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic from anywhere
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "e-commerce-alb-sg"
  }

}


