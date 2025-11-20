resource "random_password" "grafana_admin" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
  depends_on = [module.eks.cluster_name]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true
  timeout    = 900

  values = [
    yamlencode({
      grafana = {
        existingSecret = kubernetes_secret.grafana.metadata[0].name
        adminUserKey   = "admin-user"
        adminPasswordKey = "admin-password"
        service       = { type = "LoadBalancer" }
      }
      additionalDataSources = [
        {
          name      = "Prometheus"
          type      = "prometheus"
          access    = "proxy"
          url       = "http://kps-kube-prometheus-stack-prometheus.monitoring:9090/"
          isDefault = true
          jsonData  = {
            timeInterval = "30s"
          }
        }
      ]

      additionalServiceMonitors = [
        {
          name      = "web-app"
          namespace = "monitoring"
          labels    = { release = "kps" }
          selector  = { matchLabels = { app = "web-app" } }
          endpoints = [
            {
              port     = "5000"
              path     = "/metrics"
              interval = "15s"
            }
          ]
          namespaceSelector = { matchNames = ["web-app"] }
        }
      ]
    })
  ]

  depends_on = [kubernetes_namespace.monitoring, kubernetes_secret.grafana, helm_release.argocd]
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-admin-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "app.kubernetes.io/name"     = "grafana"
      "app.kubernetes.io/component" = "grafana"
    }
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.grafana_admin.result
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.monitoring]
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kps-grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.kube_prometheus_stack]
}
