module "aws-spoke-vpc" {
  count           = 1
  source          = "./aws_spoke_vpc"
  vpc_name        = format("%s-spoke-vpc-%d", var.project_prefix, count.index)
  vpc_cidr        = "10.64.0.0/22"
  bastion_cidr    = var.bastion_cidr
  owner_tag       = var.owner_tag
  providers       = {
    aws      = aws.us-east-1
  }
}

module "aws-workload" {
  count             = 1
  source            = "./aws_workload"
  site_name         = format("%s-spoke-%d", var.project_prefix, count.index)
  instance_type     = "t3.xlarge"
  aws_region        = "us-east-1"
  aws_az            = [ "a" , "b", "c" ][count.index % 3]
  vpc_id            = module.aws-spoke-vpc[0].vpc.id
  route_table_id    = module.aws-spoke-vpc[0].main_route_table_id
  security_group_id = module.aws-spoke-vpc[0].security_group.id
  subnet_cidr       = format("10.64.%d.0/24", count.index % 256)
  ssh_public_key    = var.ssh_public_key
  owner_tag         = var.owner_tag
  providers         = {
    volterra = volterra.default,
    aws      = aws.us-east-1
  }
}

module "aws-tgw-site" {
  count                = 1
  source               = "./aws_tgw_site"
  site_name            = format("%s-tgw-%d", var.project_prefix, count.index)
  aws_region           = "us-east-1"
  spoke_vpc_id         = module.aws-spoke-vpc[0].vpc.id
  service_vpc_cidr     = format("10.65.%d.0/20", (count.index % 16)*16)
  subnets              = [
    { 
      outside  = format("10.65.%d.0/24", (count.index % 16)*16+0), az = "a",
      inside   = format("10.65.%d.0/24", (count.index % 16)*16+1),
      workload = format("10.65.%d.0/24", (count.index % 16)*16+2),
    },
    { 
      outside  = format("10.65.%d.0/24", (count.index % 16)*16+4), az = "b",
      inside   = format("10.65.%d.0/24", (count.index % 16)*16+5),
      workload = format("10.65.%d.0/24", (count.index % 16)*16+6),
    },
    { 
      outside  = format("10.65.%d.0/24", (count.index % 16)*16+8), az = "c",
      inside   = format("10.65.%d.0/24", (count.index % 16)*16+9),
      workload = format("10.65.%d.0/24", (count.index % 16)*16+10),
    }
  ]
  ssh_public_key       = var.ssh_public_key
  f5xc_tenant          = var.f5xc_tenant
  f5xc_api_url         = var.f5xc_api_url
  f5xc_api_token       = var.f5xc_api_token
  f5xc_aws_cred        = var.f5xc_aws_cred
  owner_tag            = var.owner_tag
  providers            = {
    volterra = volterra.default,
    aws      = aws.us-east-1
  }
}

module "apps" {
  depends_on        = [module.aws-tgw-site]
  count             = 1
  source            = "./apps"
  domains           = ["workload.site"]
  origin_port       = 8080
  apps_name         = format("%s-aws-app-%d", var.project_prefix, count.index)
  advertise_port    = 80
  namespace         = module.namespace.namespace["name"]
  origin_servers = {
    module.aws-tgw-site[count.index].tgw["name"]: { ip = module.aws-workload[count.index].workload_private_ip },
  }
  advertise_sites = module.aws-tgw-site[*].tgw["name"]
  providers       = {
    volterra = volterra.default
  }
}

module "namespace" {
  source              = "./modules/f5xc/namespace"
  f5xc_namespace_name = format("%s-tgw-lab", var.project_prefix)
  providers           = {
    volterra = volterra.default
  }
}

output "namespace" {
  value = module.namespace
}

output "aws-spoke-vpc" {
  value = module.aws-spoke-vpc
}

output "aws-tgw-site" {
  value = module.aws-tgw-site
}

output "aws-workload" {
  value = module.aws-workload
}

output "apps" {
  value = module.apps
}
