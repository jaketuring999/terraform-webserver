

resource "aws_s3_bucket" "elb_logs" {
  bucket = var.bucket_name # Ensure this name is globally unique
  # Pick zone
  tags = {
    Name = "elb_logs"
  }
}

resource "aws_s3_bucket_public_access_block" "elb_logs_pab" {
  bucket = aws_s3_bucket.elb_logs.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "elb_logs_ownership" {
  bucket = aws_s3_bucket.elb_logs.id
  # BucketOwnerPreferred means that the bucket owner will automatically
  # assume ownership of objects that are uploaded with no specific ACL
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "elb_logs_policy" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = data.aws_iam_policy_document.elb_logs_policy.json
}

data "aws_iam_policy_document" "elb_logs_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.elb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      # Refers to access control list (ACL) of the object
      variable = "s3:x-amz-acl"
      # The value of the ACL must be bucket-owner-full-control
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.elb_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}
