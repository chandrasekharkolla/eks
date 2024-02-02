data "aws_availability_zones" "available" {}

# ################################################################################
# # KMS
# ################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  aliases               = ["eks/${var.cluster_kms_key}"]
  description           = "${var.cluster_kms_key} cluster encryption key"
  enable_default_policy = true
  #   key_owners            = var.kms_key_owners
  #   key_administrators    = var.kms_key_owners
  tags = local.eks_cluster_tags
}

# module "ebs_kms_key" {
#   source  = "terraform-aws-modules/kms/aws"
#   version = "~> 1.5"

#   description = "Customer managed key to encrypt EKS managed node group volumes"

#   # Policy
#   key_administrators = var.kms_key_owners

#   key_service_roles_for_autoscaling = [
#     # required for the ASG to manage encrypted volumes for nodes
#     "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
#     # required for the cluster / persistentvolume-controller to create encrypted PVCs
#     module.eks.cluster_iam_role_arn
#   ]

#   # Aliases
#   aliases = ["eks/${var.cluster_name}/ebs"]

#   tags = local.eks_cluster_tags
# }

# data "terraform_remote_state" "network" {
#   count   = var.remote_state_data == true ? 1 : 0
#   backend = "s3"
#   config = {
#     bucket = "hs-${var.account_name}-terraform-${var.region}"
#     key    = "${var.network_repo}/base/terraform.tfstate"
#     region = var.region
#   }
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  # source = "git@gitlab.com:amfament/homesite/devops-tooling-enablement/terraform-modules/eks.git?ref=19.10.1"
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.21.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_enabled_log_types       = ["audit", "api", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    /* aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    } */
  }

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  iam_role_additional_policies = {
    additional = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = local.subnet_ids
  control_plane_subnet_ids = local.control_plane_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    attach_cluster_primary_security_group = true

    iam_role_additional_policies = {
      additional = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    (var.linux_node_group_name) = {
      name                       = var.linux_node_group_name
      use_name_prefix            = false
      ami_type                   = var.linux_node_group_ami_type
      ami_id                     = data.aws_ami.eks_opt_linux_ami.image_id
      use_custom_launch_template = false
      min_size                   = var.linux_node_group_min_size
      max_size                   = var.linux_node_group_max_size
      desired_size               = var.linux_node_group_min_size
      instance_types             = var.linux_node_group_instance_type
      capacity_type              = var.linux_node_group_capacity_type
      disk_size                  = var.linux_nodes_disk_size

      labels = {
        Name = var.linux_node_group_name
      }
      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "Name"                                          = var.linux_node_group_name
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
    (var.windows_node_group_name) = {
      name                       = var.windows_node_group_name
      use_name_prefix            = false
      ami_type                   = var.windows_node_group_ami_type
      ami_id                     = data.aws_ami.eks_opt_windows_ami.image_id
      use_custom_launch_template = false
      min_size                   = var.windows_node_group_min_size
      max_size                   = var.windows_node_group_max_size
      desired_size               = var.windows_node_group_min_size
      instance_types             = var.windows_node_group_instance_type
      capacity_type              = var.windows_node_group_capacity_type
      disk_size                  = var.windows_nodes_disk_size

      taints = [
        {
          key    = "os"
          value  = "windows"
          effect = "NO_SCHEDULE"
        }
      ]

      labels = {
        Name = var.windows_node_group_name
      }

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "Name"                                          = var.windows_node_group_name
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = var.auth_role_arn
      username = var.username
      groups   = ["system:masters"]
    },
    # {
    #   rolearn  = module.eks.eks_managed_node_groups[var.windows_node_group_name]["iam_role_arn"]
    #   username = "system:node:{{EC2PrivateDNSName}}"
    #   groups   = ["system:nodes", "system:bootstrappers", "eks:kube-proxy-windows"]
    # },
    /* {
      rolearn  = module.iam_role_eks_service_account.iam_role_arn
      username = "sandbox-runner-role"
      groups   = ["system:masters"]
    }, */
  ]

  tags = local.eks_cluster_tags ## Work on tags to change as per the resource
}

resource "kubernetes_config_map_v1_data" "amazon_vpc_cni_cm" {
  metadata {
    name      = "amazon-vpc-cni"
    namespace = "kube-system"
  }
  data = {
    "enable-windows-ipam" = "true"
  }
  force = true
  depends_on = [
    module.eks.aws_eks_addon
  ]
}

module "ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "5.11.2"
  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.eks_cluster_tags
}

################################################################################
# EKS Module
################################################################################

locals {
  eks_cluster_tags = {
    "Moudle"   = "terraform-aws-eks"
    "Used_for" = "gitlab-runners"
    "Region"   = var.region
  }

  vpc_id                   = (var.remote_state_data == true && var.network_repo != "" && var.bucket_name != "" && var.vpc_id == "") ? data.terraform_remote_state.network[0].outputs.vpc_id : var.vpc_id
  subnet_ids               = (var.remote_state_data == true && var.network_repo != "" && var.bucket_name != "" && var.subnet_ids == null) ? data.terraform_remote_state.network[0].outputs.private_subnets : var.subnet_ids
  control_plane_subnet_ids = (var.remote_state_data == true && var.network_repo != "" && var.bucket_name != "" && var.control_plane_subnet_ids == null) ? data.terraform_remote_state.network[0].outputs.private_subnets : var.subnet_ids
}

module "vpc_cni_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "~> 5.0"
  role_name             = "vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.eks_cluster_tags
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "network" {
  count   = var.remote_state_data == true ? 1 : 0
  backend = "s3"
  config = {
    bucket = "hs-${var.account_name}-terraform-${var.region}"
    key    = "${var.network_repo}/base/terraform.tfstate"
    region = var.region
  }
}

data "aws_ami" "eks_opt_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.29-v*"]
  }
}

data "aws_ami" "eks_opt_windows_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Core-EKS_Optimized-1.29*"]
  }
}
