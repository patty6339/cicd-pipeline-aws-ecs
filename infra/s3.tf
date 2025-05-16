# S3 bucket to store pipeline artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "e-commerce-cicd-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_access" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


