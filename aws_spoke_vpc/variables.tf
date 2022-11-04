variable "vpc_name" {
  type        = string
}

variable "vpc_cidr" {
  type        = string
  default     = ""
}

variable "site_label" {
  type        = string
  default     = ""
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
}

variable "owner_tag" {
  type        = string
  default     = "m.wiget@f5.com"
}

variable "bastion_cidr" {
  type        = string
  default     = "0.0.0.0/0"
}

