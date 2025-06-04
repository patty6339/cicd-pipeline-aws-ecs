# Get the AWS account ID of the current caller
data "aws_caller_identity" "current" {}

# Get authorization token for Amazon ECR registry access
data "aws_ecr_authorization_token" "token" {}


data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}