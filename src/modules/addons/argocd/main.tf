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

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.argocd.metadata.0.name


  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  values = [
    yamlencode(
      {
        server = {
          service = {
            annotations = {
              "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
              "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
              "service.beta.kubernetes.io/aws-load-balancer-attributes"      = "load_balancing.cross_zone.enabled=true"
              "service.beta.kubernetes.io/aws-load-balancer-name"            = "argo"
            }
          }
        }
      }
    )
  ]
}

# resource "helm_release" "image_updater" {
#   name            = "argocd-image-updater"
#   repository      = "https://argoproj.github.io/argo-helm"
#   chart           = "argocd-image-updater"
#   timeout         = 120
#   cleanup_on_fail = true
#   force_update    = false
#   namespace       = kubernetes_namespace.argocd.metadata.0.name

#   values = [
#     <<EOF
# config:
#   registries:
#     # - name: GCP Artifact Registry
#     #   api_url: https://europe-west1-docker.pkg.dev
#     #   prefix: europe-west1-docker.pkg.dev
#     #   credentials: ext:/auth/auth.sh
#     #   credsexpire: 30m
#     - name: ECR
#       api_url: https://123456789.dkr.ecr.eu-west-1.amazonaws.com
#       prefix: 123456789.dkr.ecr.eu-west-1.amazonaws.com
#       ping: yes
#       insecure: no
#       credentials: ext:/scripts/auth1.sh
#       credsexpire: 10h
# volumes:
# - configMap:
#     defaultMode: 0755
#     name: auth-cm
#   name: auth
# volumeMounts:
# - mountPath: /auth
#   name: auth
# EOF
#   ]
# }
