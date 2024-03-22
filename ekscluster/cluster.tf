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
  name               = "doit_eks_${var.region}_${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.doit_eks_lens_collector.json
}

output "doit_eks_lens_collector_arn" {
  value = aws_iam_role.doit_eks_lens_collector.arn
}

resource "aws_iam_role_policy_attachment" "doit_eks_lens_collector" {
  role       = aws_iam_role.doit_eks_lens_collector.name // oidc role
  policy_arn = var.s3_policy                             // s3 policy
}



