output "glevel_name_prefix" {
  value = local.glevel_name_prefix
}

output "tfstates_bucket_id" {
  value = aws_s3_bucket.tfstates.id
}

output "tflocks_table_name" {
  value = aws_dynamodb_table.tflocks.name
}