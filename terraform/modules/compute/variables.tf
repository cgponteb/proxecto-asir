variable "project_name" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "ami_id" {
  description = "AMI ID for the Launch Template. If empty, uses latest Ubuntu."
  type        = string
  default     = ""
}
