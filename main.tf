

data "aws_caller_identity" "current" {} # data.aws_caller_identity.current.account_id
data "aws_region" "current" {}          # data.aws_region.current.name


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

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

resource "aws_iam_role_policy_attachment" "doit_eks_lens_import" {
  role       = aws_iam_role.doit_eks_lens_import.name // cross account role
  policy_arn = aws_iam_policy.doit_eks_lens.arn       // s3 policy
}
