variable "f5xc_aws_cred" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_token" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "site_name" {
  type = string
}

variable "spoke_vpc_id" {
  type = string
}

variable "service_vpc_cidr" {
  type = string
}

variable "subnets" {
  type = list(map(string))
}

variable "owner_tag" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "custom_tags" {
  type = map(string)
  default = {}
}

variable "f5xc_tenant" {
  type = string
}

