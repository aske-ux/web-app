data "aws_eks_cluster" "main" {
  name = var.cluster_name
  depends_on = [module.eks.cluster_name]
}
data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  values = [file("values-argocd.yaml")]
}


resource "helm_release" "argocd_app" {
  name       = "argocd-app"
  chart      = "./charts/argocd-app"
  namespace  = "argocd"

  values = [yamlencode({
    appName             = "app"
    repoURL             = "https://github.com/aske-ux/app.git"
    targetRevision      = "main"
    path                = "k8s"
    destinationNamespace = "app"
  })]

  depends_on = [
    helm_release.argocd
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  depends_on = [
    module.eks,
    helm_release.argocd
  ]
}

