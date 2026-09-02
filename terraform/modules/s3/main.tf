resource "aws_s3_bucket" "files" {
  bucket = "safeshare-files-chemnitz-99"
}

resource "aws_s3_bucket_lifecycle_configuration" "life" {
  bucket = aws_s3_bucket.files.id

  rule {
    id     = "delete-after-7-days"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.files.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}