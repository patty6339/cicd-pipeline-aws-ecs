# Name of the ECS cluster
variable "ecs_cluster_name" {
  type        = string
  default     = "e-commerce-cluster"
  description = "ECS cluster name"

}

# Name of the ECS service
variable "service_name" {
  type        = string
  default     = "e-commerce-service" 
  description = "UI ECS service name"

}


# Task definition family name
variable "family" {
  type        = string
  default     = "e-commerce"
  description = "Task family name"
}


# CPU units allocated to the ECS task
variable "task_cpu" {
  type        = number
  default     = "1024"
  description = "CPU units for the task"

}

# Memory allocated to the ECS task
variable "task_memory" {
  type        = number
  default     = "2048"
  description = "Memory units for the task"

}

# Name of the container
variable "container_name" {
  type        = string
  default     = "e-commerce-application"
  description = "Container name"
}

# Name of the ECR repository
variable "repository_name" {
  type        = string
  default     = "e-commerce-repository"
  description = "ECR repository name"

}


# AWS region where resources will be created
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

# CloudWatch log group name for ECS tasks
variable "log_group_name" {
  type        = string
  default     = "e-commerce-ecs-tasks"
  description = "Log group name for the application"

}

# CIDR range for the VPC
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Name tag for the VPC
variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "e-commerce-vpc"
}

# Availability zones for VPC subnets
variable "azs" {
  type        = list(string)
  description = "Availability zones for the VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

# CIDR ranges for public subnets
variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# CIDR ranges for private subnets
variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for the VPC"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]

}

# Domain name for the application
variable "domain_name" {
  type        = string
  description = "Domain name for the application"
  default     = "7hundredtechnologies.com"

}

# Website URL for the application
variable "website_url" {
  type        = string
  description = "Website URL for the application"
  default     = "www.7hundredtechnologies.com"
}


 #Add GitHub repository and branch variables
variable "github_repo" {
  type        = string
  description = "GitHub repository for the source code (format: owner/repo)"
  default     = "OjoOluwagbenga700/E-Commerce-CICD-with-ECS"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to use for the source code"
  default     = "main"
}
