variable "eks_cluster_name" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = ""
}

variable "cluster_endpoint" {
  type    = string
  default = ""
}

variable "cluster_ca_cert" {
  type    = string
  default = ""
}

variable "oidc_provider_arn" {
  type    = string
  default = ""
}