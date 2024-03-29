# The AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  cloud {
    organization = "meerim_omurbek"

    workspaces {
      name = "First_project"
    }
  }
}

locals {
  env = "first_project"
  tags = {
    env        = "${local.env}"
    created_by = "devops"

  }

}

#LB DNS

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

