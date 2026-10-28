terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

# ---------- 1. Minikube cluster via CLI ----------
resource "null_resource" "minikube" {
  triggers = {
    cluster_name = "gitops-local"
  }

  provisioner "local-exec" {
    command = "minikube start -p gitops-local --driver=docker --cpus=4 --memory=6144 --kubernetes-version=v1.30.0 --addons=default-storageclass,storage-provisioner,ingress --insecure-registry=localhost:5000"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete -p gitops-local"
  }
}

# ---------- 2. Kubernetes & Helm Providers ----------
provider "kubernetes" {
  config_path    = "C:/Users/Rohit/.kube/config"
  config_context = "gitops-local"
}

provider "helm" {
  kubernetes {
    config_path    = "C:/Users/Rohit/.kube/config"
    config_context = "gitops-local"
  }
  # Add this to force Terraform to download the chart fresh, bypassing the missing cache
  repository_config_path = "C:/Users/Rohit/AppData/Local/Temp/helm/repository/repositories.yaml"
}

# ---------- 3. App namespace ----------
resource "kubernetes_namespace" "app" {
  metadata { 
    name = "local-app" 
  }
  depends_on = [null_resource.minikube]
}

# ---------- 4. Local Docker registry inside Minikube ----------
resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "local-registry"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "registry" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "registry" } }
    template {
      metadata { labels = { app = "registry" } }
      spec {
        container {
          name  = "registry"
          image = "registry:2"
          port { container_port = 5000 }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.app]
}

resource "kubernetes_service" "registry" {
  metadata {
    name      = "local-registry"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = { app = "registry" }
    port {
      port        = 5000
      target_port = 5000
      node_port   = 30500
    }
    type = "NodePort"
  }
}

# ---------- 5. Argo CD via Helm ----------
resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
  depends_on = [null_resource.minikube]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.1.3"

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  set {
    name  = "server.service.nodePortHttp"
    value = "30080"
  }
  depends_on = [kubernetes_namespace.argocd]
}