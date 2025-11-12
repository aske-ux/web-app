output "argocd_url" {
  value = try(
    "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}",
    "ArgoCD port-forward"
  )
}

output "get_argocd_password_command" {
  value = <<EOT
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
EOT
}

output "configure_kubectl" {
    value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1"
}

output "grafana_url" {
  value = try(
    "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}",
    "Grafana not ready yet"
  )
}

output "grafana_admin_password" {
  value     = var.grafana_admin_password
  sensitive = true
}