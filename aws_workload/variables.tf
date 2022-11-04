variable "site_name" {
  type        = string
}

variable "aws_region" {
  type        = string
}

variable "aws_az" {
  type        = string
}

variable "route_table_id" {
  type        = string
  default     = ""
}

variable "vpc_id" {
  type        = string
  default     = ""
}

variable "security_group_id" {
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  type        = string
}

variable "site_label" {
  type        = string
  default     = ""
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  type        = string
  default     = "t3.xlarge"
}

variable "ssh_public_key" {
  type        = string
}

variable "owner_tag" {
  type        = string
  default     = "m.wiget@f5.com"
}

