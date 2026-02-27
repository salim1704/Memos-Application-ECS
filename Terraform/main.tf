module "ecr" {
  source = "./modules/ecr"

  repository_name = "abdulqayoom-registry"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  region         = var.region
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
}

module "endpoints" {
  source = "./modules/endpoints"

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_id
  private_route_table_ids = module.vpc.private_route_table_ids
  vpc_cidr_block          = var.vpc_cidr_block
  vpc_endpoint_sg_id      = module.security_groups.vpc_endpoint_sg_id
}

module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_id
  alb_sg_id         = module.security_groups.alb_sg_id
  certificate_arn  = module.acm.certificate_arn
}


module "iam" {
  source = "./modules/iam"
}


module "route53" {
  source = "./modules/route53"

  domain_name  = var.domain_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "ecs" {
  source = "./modules/ecs"

  container_name             = var.container_name
  container_image            = var.container_image
  container_port             = var.container_port
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  app_count                  = var.app_count
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  aws_region                 = var.region
  private_subnet_ids     = module.vpc.private_subnet_id
  ecs_sg_id              = module.security_groups.ecs_task_sg_id
  alb_target_group_arn   = module.alb.target_group_arn
  alb_listener_https_arn = module.alb.listener_https_arn
}
