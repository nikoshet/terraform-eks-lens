// S3 Bucket
resource "aws_s3_bucket" "doit_eks_lens" {
  bucket        = "doitintl-eks-metrics-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "doit_eks_lens" {
  bucket = aws_s3_bucket.doit_eks_lens.bucket

  rule {
    id = "ExpiredDocumentsRule"

    expiration {
      days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    status = "Enabled"
  }
}

// S3 Policy
data "aws_iam_policy_document" "doit_eks_lens_s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.doit_eks_lens.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.doit_eks_lens.arn}/*"]
  }
}

resource "aws_iam_policy" "doit_eks_lens" {
  name   = "doit_eks_lens_s3_${data.aws_region.current.name}"
  policy = data.aws_iam_policy_document.doit_eks_lens_s3.json
}
