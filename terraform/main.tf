module "networking" {
  source = "./modules/networking"

  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "database" {
  source = "./modules/database"

  project_name       = var.project_name
  private_subnet_ids = module.networking.private_subnet_ids
  db_sg_id           = module.security.db_sg_id
}

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  bastion_sg_id      = module.security.bastion_sg_id
  app_sg_id          = module.security.app_sg_id
  target_group_arn   = module.alb.target_group_arn
  ami_id             = var.app_ami_id

  # Database configuration for runtime
  db_endpoint = module.database.db_endpoint
  db_name     = module.database.db_name
  db_user     = module.database.db_user
  db_password = module.database.db_password
}

module "dns" {
  source = "./modules/dns"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  db_endpoint  = module.database.db_endpoint
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id # Need to output this from ALB module
}
