output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region
}

output "deployment_id" {
  value = var.cluster.deployment_id
}

output "collector_deployment" {
  value       = var.deploy_manifests ? "${local.namespace}/${kubernetes_deployment.collector[0].metadata[0].name}" : "Not managed by this module"
  description = "Collector deployment name"
}

output "kube_state_metrics_deployment" {
  value       = var.deploy_manifests ? "${local.namespace}/${kubernetes_deployment.kube_state_metrics[0].metadata[0].name}" : "Not managed by this module"
  description = "Kube-state-metrics deployment name"
}
