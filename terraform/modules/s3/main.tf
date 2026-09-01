resource "aws_s3_bucket" "safeshare" {
  bucket = "${var.project_name}-files-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.project_name}-files"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "safeshare" {
  bucket = aws_s3_bucket.safeshare.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "safeshare" {
  bucket = aws_s3_bucket.safeshare.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "safeshare" {
  bucket = aws_s3_bucket.safeshare.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "safeshare" {
  bucket = aws_s3_bucket.safeshare.id

  rule {
    id     = "finops-transition-to-ia"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

data "aws_caller_identity" "current" {}
