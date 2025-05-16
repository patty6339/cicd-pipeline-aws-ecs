# Get the AWS account ID of the current caller
data "aws_caller_identity" "current" {}

# Get authorization token for Amazon ECR registry access
data "aws_ecr_authorization_token" "token" {}
