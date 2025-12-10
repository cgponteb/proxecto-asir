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

variable "db_endpoint" {
  description = "RDS database endpoint (hostname:port)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "todo"
}

variable "db_user" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Number of application instances to launch"
  type        = number
}
