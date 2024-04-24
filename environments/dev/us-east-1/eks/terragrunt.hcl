# include "root" {
#   path = find_in_parent_folders()
# }

# terraform {
#   source = "${get_parent_terragrunt_dir()}//src/modules/eks"
# }

# dependency "vpc" {
#   config_path = "../vpc"
# }

# locals {
#   region = "us-east-1"
#   node_groups_configs = {
#     "linux" = {
#       name                       = "first-linux"
#       use_name_prefix            = false
#       ami_type                   = "AL2_x86_64"
#       ami_id                     = "linux"
#       create_launch_template     = true
#       use_custom_launch_template = true
#       min_size                   = 3
#       max_size                   = 15
#       desired_size               = 3
#       instance_types             = ["t3.medium"]
#       capacity_type              = "ON_DEMAND"
#       disk_size                  = 20

#       labels = {
#         Name = "my-cluster"
#       }
#       update_config = {
#         max_unavailable_percentage = 33 # or set `max_unavailable`
#       }

#       enable_bootstrap_user_data = true
#       ebs_optimized              = true
#       /* pre_bootstrap_user_data    = "" */
#       #   block_device_mappings = {
#       #     xvda = {
#       #       device_name = "/dev/xvda"
#       #       ebs = {
#       #         volume_size = 30
#       #         volume_type = "gp2"
#       #         # iops        = 3000
#       #         # throughput  = 150
#       #         # encrypted   = true
#       #         # kms_key_id            = module.ebs_kms_key.key_arn
#       #         delete_on_termination = true
#       #       }
#       #     }
#       #   }

#       tags = {
#         "k8s.io/cluster-autoscaler/my-cluster" = "owned"
#         "k8s.io/cluster-autoscaler/enabled"    = "true"
#         "Name"                                 = "linux"
#       }
#       metadata_options = {
#         http_endpoint               = "enabled"
#         http_tokens                 = "required"
#         http_put_response_hop_limit = 2
#         instance_metadata_tags      = "disabled"
#       }
#     }
#   }
# }

# generate "provider" {
#   path      = "provider.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
#     provider "aws" {
#       region = "${local.region}"
#     }
# EOF
# }

# remote_state {
#   backend = "s3"

#   config = {
#     bucket         = "test-eks-terraform-remote-state"
#     dynamodb_table = "DynamoDBTerraformStateLockTable"
#     encrypt        = true
#     region         = local.region
#     key            = "eks.tfstate"
#   }

#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }

# inputs = {

#   # Common Configs
#   region                   = local.region
#   cluster_name             = "my-cluster"
#   cluster_version          = 1.29
#   vpc_id                   = dependency.vpc.outputs.vpc_id
#   subnet_ids               = dependency.vpc.outputs.private_subnets
#   control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets
#   cluster_kms_key          = "my-cluster"
#   node_groups_configs      = local.node_groups_configs
#   kms_key_owners = []
# }

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//src/modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = ""
    private_subnets = [""]
    intra_subnets   = [""]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
    }
EOF
}

# iam_role = "arn:aws:iam::${local.account_vars.locals.account_number}:role/devops-iac"

remote_state {
  backend = "s3"

  config = {
    bucket         = "test-eks-terraform-remote-state"
    dynamodb_table = "DynamoDBTerraformStateLockTable"
    encrypt        = true
    region         = local.region
    key            = "eks.tfstate"
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
  cluster_name             = "my-cluster"
  cluster_version          = 1.29
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets
  cluster_kms_key          = "my-cluster"
  # kms_key_owners = []
  linux_node_group_name            = "linux"
  linux_node_group_ami_type        = "AL2_x86_64"
  linux_node_group_min_size        = 3
  linux_node_group_max_size        = 15
  linux_node_group_instance_type   = ["t3.medium"]
  linux_node_group_capacity_type   = "SPOT"
  linux_nodes_disk_size            = 20
  windows_node_group_name          = "windows"
  windows_node_group_ami_type      = "WINDOWS_CORE_2019_x86_64"
  windows_node_group_min_size      = 3
  windows_node_group_max_size      = 10
  windows_node_group_instance_type = ["t3.medium"]
  windows_node_group_capacity_type = "SPOT"
  windows_nodes_disk_size          = 50
  auth_role_arn                    = "arn:aws:iam::${get_aws_account_id()}:role/hs-infra-admin"
  username                         = "hs-infra-admin"
  region                           = local.region
}

/* vpc_id                   = "vpc-0eb2d467a125f14f3"
subnet_ids               = ["subnet-04cb1083a69a6a3eb", "subnet-03c73e1026406d9a8", "subnet-0f1fb46d719c37a6c"]
control_plane_subnet_ids = ["subnet-04cb1083a69a6a3eb", "subnet-03c73e1026406d9a8", "subnet-0f1fb46d719c37a6c"] */
