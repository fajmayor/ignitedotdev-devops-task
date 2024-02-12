# kubectl terraform provider
terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
    
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }

  }
}

# configure kubectl provider
provider "kubectl" {
  load_config_file = true
  config_path = "~/.kube/ignite-cluster-kubeconfig"

}

data "kubectl_path_documents" "docs" {
    pattern = "./manifests/*.yaml"
}

resource "kubectl_manifest" "deployment" {

    for_each  = toset(data.kubectl_path_documents.docs.documents)
    yaml_body = each.value
}

# configure provider for helm
provider "helm" {
  kubernetes {
    config_path = "~/.kube/ignite-cluster-kubeconfig"
  }
}

provider "kubernetes" {
   config_path = "~/.kube/ignite-cluster-kubeconfig"
}

# create monitoring namespace
resource "kubernetes_namespace" "kube-namespace" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.kube-namespace.id
  create_namespace = true
  version    = "45.7.1"
  values = [
    file("values.yaml")
  ]
  timeout = 2000
  

set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

/* resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace  = kubernetes_namespace.kube-namespace.id
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.grafana.result
  }
}

resource "random_password" "grafana" {
  length = 24
}

resource "helm_release" "grafana" {
  chart      = "grafana"
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = kubernetes_namespace.kube-namespace.id
  version    = "6.24.1"

  values = [
    templatefile("${path.module}/templates/grafana-values.yaml", {
      admin_existing_secret = kubernetes_secret.grafana.metadata[0].name
      admin_user_key        = "admin-user"
      admin_password_key    = "admin-password"
      prometheus_svc        = "${helm_release.prometheus.name}-server"
      replicas              = 1
    })
  ]
} */