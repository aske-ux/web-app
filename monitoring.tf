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
        adminPassword = var.grafana_admin_password
        service       = { type = "LoadBalancer" }
      }

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

  depends_on = [kubernetes_namespace.monitoring, helm_release.argocd]
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kps-grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.kube_prometheus_stack]
}
