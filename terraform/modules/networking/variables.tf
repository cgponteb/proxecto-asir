variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for tags"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}
