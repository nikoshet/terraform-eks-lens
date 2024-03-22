locals {
  labels = {
    "app.kubernetes.io/name" = "doit_eks_lens"
  }
}

resource "kubernetes_namespace_v1" "doit_eks_metrics" {
  metadata {
    name = "doit-eks-metrics"
  }
}

resource "kubernetes_service_account" "doit_kube_state_metrics" {
  metadata {
    name      = "doit-kube-state-metrics"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "doit_kube_state_metrics" {
  metadata {
    name   = "doit-kube-state-metrics"
    labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "nodes", "pods", "services", "serviceaccounts", "resourcequotas", "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "daemonsets", "deployments", "replicasets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "volumeattachments"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingressclasses", "ingresses"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterrolebindings", "clusterroles", "rolebindings", "roles"]
    verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "doit_kube_state_metrics" {
  metadata {
    name   = "doit-kube-state-metrics"
    labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.doit_kube_state_metrics.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.doit_kube_state_metrics.metadata[0].name
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
  }
}

resource "kubernetes_deployment" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels    = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
  }

  spec {
    replicas = 1

    selector {
      match_labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
    }

    template {
      metadata {
        labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
      }

      spec {
        service_account_name            = kubernetes_service_account.doit_kube_state_metrics.metadata[0].name
        automount_service_account_token = true

        container {
          name  = "kube-state-metrics"
          image = var.cluster.kube_state_image

          image_pull_policy = "IfNotPresent"

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          args = [
            "--port=8080",
            "--resources=cronjobs,daemonsets,deployments,jobs,nodes,pods,replicasets,replicationcontrollers,resourcequotas,statefulsets",
            "--metric-labels-allowlist=pods=[*],nodes=[*]",
          ]

          port {
            container_port = 80
            name           = "http-metrics"
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 8080
              scheme = "HTTP"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/"
              port   = 8080
              scheme = "HTTP"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels    = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
  }

  spec {
    cluster_ip = "None"

    port {
      name        = "http-metrics"
      port        = 8080
      target_port = 8080
    }

    selector = merge(local.labels, { "app.kubernetes.io/component" = "doit-kube-state-metrics" })
  }
}

resource "kubernetes_service_account" "doit_collector" {
  metadata {
    name      = "doit-collector"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels    = merge(local.labels, { "app.kubernetes.io/component" = "doit-collector" })

    // conditionally add the eks.amazonaws.com/role-arn annotation if the AWS access key is not provided (used for ec2 cluster deployments)
    annotations = {
      "eks.amazonaws.com/role-arn" = var.ec2_cluster == false ? var.role_arn : ""
    }
  }
}

resource "kubernetes_cluster_role" "doit_otel" {
  metadata {
    name   = "doit-otel"
    labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-collector" })
  }

  rule {
    api_groups = [""]
    resources  = ["events", "namespaces", "namespaces/status", "nodes", "nodes/spec", "nodes/stats", "nodes/proxy", "pods", "pods/status", "replicationcontrollers", "replicationcontrollers/status", "resourcequotas", "services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["daemonsets", "deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "endpoints"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/stats", "configmaps", "events"]
    verbs      = ["create", "get"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["otel-container-insight-clusterleader"]
    verbs          = ["get", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "doit_otel" {
  metadata {
    name   = "doit-otel"
    labels = merge(local.labels, { "app.kubernetes.io/component" = "doit-collector" })
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.doit_otel.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.doit_collector.metadata[0].name
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
  }
}

resource "kubernetes_config_map" "doit_collector_config" {
  metadata {
    name      = "doit-collector-config"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels = merge(local.labels, {
      "app.kubernetes.io/component"    = "doit-collector"
      "doit.com/metrics-deployment-id" = var.cluster.deployment_id
    })
  }

  data = {
    "collector.yaml" = "${templatefile(
      "${path.module}/collector-config.yaml",
      {
        doit_metrics_deployment_id = var.cluster.deployment_id
        collector_bucket_name      = var.s3_bucket
        collector_bucket_prefix    = "eks-metrics/${var.account_id}/${var.region}/${var.cluster.cluster_name}"
        region                     = var.region
      }
    )}"
  }
}

// conditionally create a secret for the AWS access key if it is provided (used for ec2 cluster deployments)
resource "kubernetes_secret" "collector_access_key" {
  count = var.ec2_cluster == true ? 1 : 0

  metadata {
    name      = "aws-access-key-id"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels = merge(local.labels, {
      "app.kubernetes.io/component"    = "doit-collector"
      "doit.com/metrics-deployment-id" = var.cluster.deployment_id
    })
  }

  data = {
    AWS_ACCESS_KEY_ID = var.aws_access_key
  }

  type = "kubernetes.io/generic"
}

// conditionally create a secret for the AWS secret access key if it is provided (used for ec2 cluster deployments)
resource "kubernetes_secret" "collector_seccret_key" {
  count = var.ec2_cluster == true ? 1 : 0

  metadata {
    name      = "aws-secret-access-key"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels = merge(local.labels, {
      "app.kubernetes.io/component"    = "doit-collector"
      "doit.com/metrics-deployment-id" = var.cluster.deployment_id
    })
  }

  data = {
    AWS_SECRET_ACCESS_KEY = var.aws_secret_key
  }

  type = "kubernetes.io/generic"
}

resource "kubernetes_deployment" "collector" {
  depends_on = [kubernetes_config_map.doit_collector_config]

  metadata {
    name      = "collector"
    namespace = kubernetes_namespace_v1.doit_eks_metrics.metadata[0].name
    labels = merge(local.labels, {
      "app.kubernetes.io/component"    = "doit-collector"
      "doit.com/metrics-deployment-id" = var.cluster.deployment_id
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = merge(local.labels, {
        "app.kubernetes.io/component"    = "doit-collector"
        "doit.com/metrics-deployment-id" = var.cluster.deployment_id
      })

    }

    template {
      metadata {
        labels = merge(local.labels, {
          "app.kubernetes.io/component"    = "doit-collector"
          "doit.com/metrics-deployment-id" = var.cluster.deployment_id
        })
      }

      spec {
        restart_policy       = "Always"
        service_account_name = "doit-collector"

        container {
          name  = "otelcol"
          image = var.cluster.otel_image

          image_pull_policy = "IfNotPresent"

          args = ["--config=/conf/collector.yaml"]

          // conditionally mount the AWS access key secret if it is provided (used for ec2 cluster deployments)
          dynamic "env" {
            for_each = var.ec2_cluster == true ? [true] : []
            content {
              name = "AWS_ACCESS_KEY_ID"
              value_from {
                secret_key_ref {
                  name = "aws-access-key-id"
                  key  = "AWS_ACCESS_KEY_ID"
                }
              }
            }

          }

          // conditionally mount the AWS secret access key secret if it is provided (used for ec2 cluster deployments)
          dynamic "env" {
            for_each = var.ec2_cluster == true ? [true] : []
            content {
              name = "AWS_SECRET_ACCESS_KEY"
              value_from {
                secret_key_ref {
                  name = "aws-secret-access-key"
                  key  = "AWS_SECRET_ACCESS_KEY"
                }
              }
            }
          }

          env {
            name = "K8S_NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "K8S_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            mount_path = "/conf"
            name       = "doit-collector-config"
            read_only  = true
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/"
              port   = 13133
              scheme = "HTTP"
            }
            period_seconds    = 10
            success_threshold = 1
            timeout_seconds   = 1
          }
        }

        volume {
          name = "doit-collector-config"

          config_map {
            default_mode = "0640"
            name         = "doit-collector-config"

            items {
              key  = "collector.yaml"
              path = "collector.yaml"
            }
          }
        }
      }
    }
  }
}

output "collector" {
  value = kubernetes_deployment.collector.metadata[0].name
}
