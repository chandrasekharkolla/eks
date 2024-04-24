include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//src/modules/addons/aws-lb-controller"
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_endpoint                   = ""
    cluster_certificate_authority_data = ""
    oidc_provider_arn                  = ""
    cluster_name                       = ""
  }
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
    }

    provider "kubernetes" {
      host                   = "${dependency.eks.outputs.cluster_endpoint}"
      cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
        command     = "aws"
      }
    }
EOF
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "test-eks-terraform-remote-state"
    dynamodb_table = "DynamoDBTerraformStateLockTable"
    encrypt        = true
    region         = local.region
    key            = "aws-lb-controller.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

locals {
  region = "us-east-1"
}

inputs = {
  eks_cluster_name  = "my-cluster"
  vpc_id            = dependency.vpc.outputs.vpc_id
  cluster_endpoint  = dependency.eks.outputs.cluster_endpoint
  cluster_ca_cert   = dependency.eks.outputs.cluster_certificate_authority_data
  region            = local.region
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
}
