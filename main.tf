
// DoitCrossAccountRole to access s3 bucket
data "aws_iam_policy_document" "doit_eks_lens_import" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::068664126052:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "doit_eks_lens_import" {
  name               = "doitintl_eks_import"
  assume_role_policy = data.aws_iam_policy_document.doit_eks_lens_import.json
}

// S3 Bucket
resource "aws_s3_bucket" "doit_eks_lens" {
  bucket        = "doitintl-eks-metrics-${var.account_id}-${var.region}"
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
  name   = "doitintl_eks_s3"
  policy = data.aws_iam_policy_document.doit_eks_lens_s3.json
}


// OIDC policy
data "aws_iam_policy_document" "doit_eks_lens_collector" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}",
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:doit-eks-metrics:doit-collector",
      ]
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role" "doit_eks_lens_collector" {
  // Create a role for the OIDC provider if no access key is provided
  count = var.ec2_cluster == false ? 1 : 0

  name               = "doit_eks_${var.region}_${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.doit_eks_lens_collector.json
}

resource "aws_iam_user" "doit_eks_lens_collector" {
  // create conditional user if no access key is provided
  count = var.ec2_cluster == true ? 1 : 0
  name  = "doit_eks_lens_collector"
  path  = "/"
}

resource "aws_iam_access_key" "doit_eks_lens_collector" {
  count = var.ec2_cluster == true ? 1 : 0

  user = aws_iam_user.doit_eks_lens_collector[0].id
}

// Attach policies to roles
resource "aws_iam_role_policy_attachment" "doit_eks_lens_collector" {
  // Attach the S3 policy to the OIDC role if no access key is provided
  count = var.ec2_cluster == false ? 1 : 0

  role       = aws_iam_role.doit_eks_lens_collector[0].name // oidc role
  policy_arn = aws_iam_policy.doit_eks_lens.arn             // s3 policy

  depends_on = [aws_iam_role.doit_eks_lens_collector[0]]
}

resource "aws_iam_user_policy_attachment" "iam_policy" {
  count = var.ec2_cluster == true ? 1 : 0

  policy_arn = aws_iam_policy.doit_eks_lens.arn // s3 policy
  user       = aws_iam_user.doit_eks_lens_collector[0].name
}

resource "aws_iam_role_policy_attachment" "doit_eks_lens_import" {
  role       = aws_iam_role.doit_eks_lens_import.name // cross account role
  policy_arn = aws_iam_policy.doit_eks_lens.arn       // s3 policy
}
