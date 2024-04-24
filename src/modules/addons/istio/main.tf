provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }


  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  values = [
    yamlencode(
      {
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-attributes"      = "load_balancing.cross_zone.enabled=true"
            "service.beta.kubernetes.io/aws-load-balancer-name"            = "istio-nlb"
          }
        }
      }
    )
  ]

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
  #   value = "internet-facing"
  # }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
  #   value = "external"
  # }

  # # set {
  # #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-attributes"
  # #   value = "{\"load_balancing.cross_zone.enabled\": \"true\"}"
  # # }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
  #   value = "ip"
  # }

  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
  #   value = "istio-nlb"
  # }

  depends_on = [helm_release.istiod]
}
