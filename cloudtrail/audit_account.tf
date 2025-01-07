# S3 Bucket
resource "aws_s3_bucket" "cloudtrail_bucket" {
  provider = aws.audit_account

  bucket_prefix = "cloudtrail-logs-"
  force_destroy = true # Set to true only for testing purposes.

  tags = {
    Name        = "CloudTrail log storage"
    Environment = "Prod"
  }
}

# Best Practice - Enable versioning on s3 bucket
resource "aws_s3_bucket_versioning" "cloudtrail_bucket" {
  provider = aws.audit_account

  bucket = aws_s3_bucket.cloudtrail_bucket.id
  versioning_configuration {
    status = "Enabled"
    # mfa_delete = "Enabled"
  }
}

# Best Practice - Lifecycle Management
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket" {
  provider = aws.audit_account

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.cloudtrail_bucket]

  bucket = aws_s3_bucket.cloudtrail_bucket.id

  rule {
    id = "prod"

    filter {
      prefix = "prod/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 1095
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 365
      storage_class   = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 1095
    }

    status = "Enabled"
  }

  rule {
    id = "dev"

    filter {
      prefix = "dev/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  provider = aws.audit_account

  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_policy.json
}

data "aws_iam_policy_document" "cloudtrail_policy" {
  provider = aws.audit_account

  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "this" {
  provider = aws.audit_account

  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket" {
  provider = aws.audit_account

  bucket = aws_s3_bucket.cloudtrail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Bucket logging
resource "aws_s3_bucket" "log_bucket" {
  provider = aws.audit_account

  bucket_prefix = "server-access-logs-"
  force_destroy = true # Set to true only for testing purposes.

  tags = {
    Name        = "Server Access Logs for CloudTrail S3 Bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_bucket" {
  provider = aws.audit_account

  bucket = aws_s3_bucket.cloudtrail_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "this" {
  name              = "/organization/management_events"
  skip_destroy      = true
  retention_in_days = 30
  kms_key_id        = aws_kms_key.this.arn

  tags = {
    Environment = "Prod"
  }
}