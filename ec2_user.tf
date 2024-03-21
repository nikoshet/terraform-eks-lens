// For EC2 clusters create IAM user for EKS Lens collector and attach the S3 policy to it
resource "aws_iam_user" "doit_eks_lens_collector" {
  name = "doit_eks_lens_collector_${var.region}"
  path = "/"

  force_destroy = true
}

resource "aws_iam_access_key" "doit_eks_lens_collector" {
  user       = aws_iam_user.doit_eks_lens_collector.id
  depends_on = [aws_iam_user.doit_eks_lens_collector]
}

resource "aws_iam_user_policy_attachment" "iam_policy" {
  policy_arn = aws_iam_policy.doit_eks_lens.arn // s3 policy
  user       = aws_iam_user.doit_eks_lens_collector.name
  depends_on = [aws_iam_user.doit_eks_lens_collector, aws_iam_policy.doit_eks_lens]
}
