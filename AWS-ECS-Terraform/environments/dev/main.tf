provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  availability_zones = var.availability_zones
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id     = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  vpc_id           = module.vpc.vpc_id
  security_group_id = module.security.alb_security_group_id
  subnet_ids       = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "../../modules/ecs"

  environment           = var.environment
  subnet_ids           = module.vpc.public_subnet_ids
  security_group_id    = module.security.ecs_security_group_id
  target_group_arn     = module.alb.target_group_arn
  container_cpu        = var.container_cpu
  container_memory     = var.container_memory
  service_desired_count = var.service_desired_count
}