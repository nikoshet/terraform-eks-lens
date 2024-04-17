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
  value       = "${local.namespace}/${kubernetes_deployment.collector.metadata[0].name}"
  description = "Collector deployment name"
}

output "kube_state_metrics_deployment" {
  value       = "${local.namespace}/${kubernetes_deployment.kube_state_metrics.metadata[0].name}"
  description = "Kube-state-metrics deployment name"
}
