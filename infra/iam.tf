

# Creates an IAM role that ECS tasks can assume, using the trust policy defined above
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "EcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "EcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

# Attaches the AWS managed policy that grants permissions needed by the ECS task execution service

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attaches the AWS Systems Manager policy required for ECS Exec functionality

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "e-commerce-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CodeBuild
resource "aws_iam_policy" "codebuild_policy" {
  name        = "e-commerce-codebuild-policy"
  description = "Policy for CodeBuild to access required resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["ecs:DescribeTaskDefinition", "ecs:RegisterTaskDefinition"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.ecs_task_execution_role.arn
      }
    ]
  })
}

# Attach policy to CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

# IAM role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "e-commerce-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policy for CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


# IAM role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "e-commerce-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CodePipeline
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "e-commerce-codepipeline-policy"
  description = "Policy for CodePipeline to access required resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketVersioning", "s3:PutObject"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      {
        Action   = ["codestar-connections:UseConnection"]
        Effect   = "Allow"
        Resource = aws_codestarconnections_connection.github_connection.arn
      },
      {
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Effect   = "Allow"
        Resource = aws_codebuild_project.e_commerce_build.arn
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Effect   = "Allow"
        Resource = [
          aws_codedeploy_app.e_commerce_app.arn,
          aws_codedeploy_deployment_group.e_commerce_deployment_group.arn
        ]
      },
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster:e-commerce-cluster"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "ecs-tasks.amazonaws.com",
              "codedeploy.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# Attach policy to CodePipeline role
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}
