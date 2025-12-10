output "alb_dns_name" {
  description = "Public DNS name of the Load Balancer"
  value       = module.alb.alb_dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = module.compute.bastion_public_ip
}

output "db_endpoint" {
  description = "Database Endpoint"
  value       = module.database.db_endpoint
}

output "db_password" {
  description = "Database Password (Sensitive)"
  value       = module.database.db_password
  sensitive   = true
}

output "private_zone_domain" {
  description = "Private Route53 Zone Name"
  value       = "${var.project_name}.internal"
}

output "build_server_private_ip" {
  description = "Private IP of the Build Server"
  value       = module.compute.build_server_private_ip
}
