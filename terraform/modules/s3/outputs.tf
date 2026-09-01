output "s3_bucket_name" {
  value = aws_s3_bucket.safeshare.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.safeshare.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.safeshare.id
}
