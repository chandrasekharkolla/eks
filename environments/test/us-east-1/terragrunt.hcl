include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//src/modules/vpc"
}

inputs = {
  tags = {
    "Name" = "EKS-VPC"
  }
  vpc_cidr = "10.0.0.0/16"
}