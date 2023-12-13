terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.25.0"
    }
  }
}


provider "aws" {
  region = "us-east-2"
  shared_config_files = ["/mnt/c/users/Igor/.aws/congig"]
  shared_credentials_files = ["/mnt/c/users/Igor/.aws/credentials"]
}


# ----------------------------------------------------------------------------- locals
locals {
  glevel_name_prefix = "%{for i, el in var.glevel_name_structure}${el}%{if i < length(var.glevel_name_structure) - 1}-%{endif}%{endfor}"
}

# ----------------------------------------------------------------------------- S3 bucket
resource "aws_s3_bucket" "tfstates" {
  bucket = "${local.glevel_name_prefix}-tfstates"
  force_destroy = true
  tags = {Name = "${local.glevel_name_prefix}-tfstates"}
}

resource "aws_s3_bucket_public_access_block" "block_tfstates" {
  bucket = aws_s3_bucket.tfstates.id
  ignore_public_acls = true
  block_public_acls = true
  restrict_public_buckets = true
  block_public_policy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.tfstates.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.tfstates.id
  versioning_configuration {
    status = "Enabled"
  }
}


# ----------------------------------------------------------------------------- DynamoDB table
resource "aws_dynamodb_table" "tflocks" {
  name = "${local.glevel_name_prefix}-tflocks"
  attribute {
    name = "LockID"
    type = "S"
  }
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  tags = {Name = "${local.glevel_name_prefix}-tflocks"}
}