module "eks-cluster-951" {
  source = "./ekscluster"

  account_id   = "626859882963" // data.aws_caller_identity.current.account_id
  region       = "us-east-1"    // var.region
  cluster_name = "eks-cluster-951"

  role_arn = aws_iam_role.doit_eks_lens_import.arn

  s3_bucket = aws_s3_bucket.doit_eks_lens.id
  s3_policy = aws_iam_policy.doit_eks_lens.arn

  // OpenID Connect provider URL
  cluster_oidc_issuer_url = "https://oidc.eks.us-east-1.amazonaws.com/id/838CD4C82C1E964993BAB44CC0F11C9E"
}

module "k8s_eks-cluster-951" {
  source = "./k8s"

  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1" // var.region

  cluster = {
    cluster_name     = "eks-cluster-951"
    deployment_id    = "AKD6ikz4k3Z52rF9sXew"
    kube_state_image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2"
    otel_image       = "otel/opentelemetry-collector-contrib:0.83.0"
  }

  ec2_cluster = false

  role_arn  = module.eks-cluster-951.doit_eks_lens_collector_arn
  s3_bucket = aws_s3_bucket.doit_eks_lens.id

  providers = {
    kubernetes = provider.eks-cluster-951
  }
}

## Configure Your Cluster Provider
# With .kube/config
# provider "kubernetes" {
#   alias          = "eks-cluster-951"
#   config_path    = "~/.kube/config"
#   config_context = "<<Your Cluster Context>>"
# }

# OR with AWS
# provider "kubernetes" {
#   alias                  = "eks-cluster-951"
#   host                   = data.aws_eks_cluster.<<Your Cluster>>.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.<<Your Cluster>>.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.<<Your Cluster>>.token
# }

# OR with Certificates
# provider "kubernetes" {
#   alias                  = "eks-cluster-951"
#   host                   = "https://<<Your Cluster Host>>"
#   client_certificate     = file("cert.pem")
#   client_key             = file("key.pem")
#   cluster_ca_certificate = file("~/ca-cert.pem")
# }

