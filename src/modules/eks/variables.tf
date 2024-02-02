# variable "region" {
#   type    = string
#   default = ""
# }

# variable "cluster_name" {
#   description = "EKS cluster name"
#   type        = string
#   default     = ""
# }

# variable "cluster_version" {
#   description = "EKS cluster version"
#   type        = string
#   default     = ""
# }

# variable "linux_node_group_name" {
#   description = "Name of the linux node group"
#   type        = string
#   default     = ""
# }

# variable "linux_node_group_ami_type" {
#   description = "Type of AMI of the linux node group"
#   type        = string
#   default     = ""
# }

# variable "linux_node_group_min_size" {
#   description = "Minimum number of instances in the linux node group"
#   type        = number
#   default     = 1
# }

# variable "linux_node_group_max_size" {
#   description = "Maximum number of instances in the linux node group"
#   type        = number
#   default     = 3
# }

# variable "linux_node_group_instance_type" {
#   description = "Type of the instance either medium, large etc"
#   type        = list(string)
#   default     = []
# }

# variable "linux_node_group_capacity_type" {
#   description = "Type of the node capacity like ondemand, spot, reserved"
#   type        = string
#   default     = ""
# }

# variable "linux_nodes_disk_size" {
#   description = "Disk size of the linux node group"
#   type        = number
#   default     = 20
# }

# variable "windows_node_group_name" {
#   description = "Name of the windows node group"
#   type        = string
#   default     = ""
# }

# variable "windows_node_group_ami_type" {
#   description = "Type of AMI of the windows node group"
#   type        = string
#   default     = ""
# }

# variable "windows_node_group_min_size" {
#   description = "Minimum number of instances in the windows node group"
#   type        = number
#   default     = 1
# }

# variable "windows_node_group_max_size" {
#   description = "Maximum number of instances in the windows node group"
#   type        = number
#   default     = 3
# }

# variable "windows_node_group_instance_type" {
#   description = "Type of the instance either medium, large etc"
#   type        = list(string)
#   default     = []
# }

# variable "windows_node_group_capacity_type" {
#   description = "Type of the node capacity like ondemand, spot, reserved"
#   type        = string
#   default     = ""
# }

# variable "windows_nodes_disk_size" {
#   description = "Disk size of the windows node group"
#   type        = number
#   default     = 50
# }

# variable "cluster_tags" {
#   description = "Tags for the resources created for the EKS cluster"
#   type        = string
#   default     = ""
# }

# variable "auth_role_arn" {
#   type    = string
#   default = null
# }

# variable "username" {
#   type    = string
#   default = "hs-infra-admin"
# }

# variable "account_name" {
#   type    = string
#   default = ""
# }

# variable "network_repo" {
#   type    = string
#   default = ""
# }

# /* KMS variables */

# variable "cluster_kms_key" {
#   description = "EKS cluster version"
#   type        = string
#   default     = ""
# }

# variable "cluster_kms_key_tags" {
#   description = "Tags for KMS key"
#   type        = string
#   default     = ""
# }

# variable "vpc_id" {
#   type    = string
#   default = ""
# }

# variable "subnet_ids" {
#   type    = list(string)
#   default = null
# }

# variable "control_plane_subnet_ids" {
#   type    = list(string)
#   default = null
# }

# variable "remote_state_data" {
#   type    = bool
#   default = false
# }

# variable "bucket_name" {
#   type    = string
#   default = ""
# }

# variable "node_groups_configs" {
#   type    = any
#   default = {}
# }

# variable "kms_key_owners" {
#   type    = list(string)
#   default = [""]
# }

# variable "aws_auth_roles" {
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))
#   default = [{
#     rolearn  = ""
#     username = ""
#     groups   = [""]
#   }]
# }

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}


variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = ""
}

variable "linux_node_group_name" {
  description = "Name of the linux node group"
  type        = string
  default     = ""
}

variable "linux_node_group_ami_type" {
  description = "Type of AMI of the linux node group"
  type        = string
  default     = ""
}

variable "linux_node_group_min_size" {
  description = "Minimum number of instances in the linux node group"
  type        = number
  default     = 1
}

variable "linux_node_group_max_size" {
  description = "Maximum number of instances in the linux node group"
  type        = number
  default     = 3
}

variable "linux_node_group_instance_type" {
  description = "Type of the instance either medium, large etc"
  type        = list(string)
  default     = []
}

variable "linux_node_group_capacity_type" {
  description = "Type of the node capacity like ondemand, spot, reserved"
  type        = string
  default     = ""
}

variable "linux_nodes_disk_size" {
  description = "Disk size of the linux node group"
  type        = number
  default     = 20
}

variable "windows_node_group_name" {
  description = "Name of the windows node group"
  type        = string
  default     = ""
}

variable "windows_node_group_ami_type" {
  description = "Type of AMI of the windows node group"
  type        = string
  default     = ""
}

variable "windows_node_group_min_size" {
  description = "Minimum number of instances in the windows node group"
  type        = number
  default     = 1
}

variable "windows_node_group_max_size" {
  description = "Maximum number of instances in the windows node group"
  type        = number
  default     = 3
}

variable "windows_node_group_instance_type" {
  description = "Type of the instance either medium, large etc"
  type        = list(string)
  default     = []
}

variable "windows_node_group_capacity_type" {
  description = "Type of the node capacity like ondemand, spot, reserved"
  type        = string
  default     = ""
}

variable "windows_nodes_disk_size" {
  description = "Disk size of the windows node group"
  type        = number
  default     = 50
}

variable "cluster_tags" {
  description = "Tags for the resources created for the EKS cluster"
  type        = string
  default     = ""
}

variable "auth_role_arn" {
  type    = string
  default = null
}

variable "username" {
  type    = string
  default = "hs-infra-admin"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_name" {
  type    = string
  default = ""
}

variable "network_repo" {
  type    = string
  default = ""
}

/* KMS variables */

variable "cluster_kms_key" {
  description = "EKS cluster version"
  type        = string
  default     = ""
}

variable "cluster_kms_key_tags" {
  description = "Tags for KMS key"
  type        = string
  default     = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "control_plane_subnet_ids" {
  type    = list(string)
  default = null
}

variable "remote_state_data" {
  type    = bool
  default = false
}

variable "bucket_name" {
  type    = string
  default = ""
}
