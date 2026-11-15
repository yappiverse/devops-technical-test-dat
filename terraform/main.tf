module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  data_subnet_cidrs   = var.data_subnet_cidrs
}

module "database" {
  source = "./modules/database"

  project_name                          = var.project_name
  environment                           = var.environment
  vpc_id                                = module.networking.vpc_id
  data_subnet_ids                       = module.networking.data_subnet_ids
  app_security_group_id                 = module.networking.backend_security_group_id
  db_instance_class                     = var.db_instance_class
  db_multi_az                           = var.db_multi_az
  performance_insights_enabled          = var.db_performance_insights_enabled
  performance_insights_retention_period = var.db_performance_insights_retention_period
  redis_node_type                       = var.redis_node_type
  redis_num_cache_clusters              = var.redis_num_cache_clusters
}


module "etc" {
  source = "./modules/etc"

  project_name     = var.project_name
  environment      = var.environment
  db_host          = module.database.db_address
  db_password      = module.database.db_password
  redis_host       = module.database.redis_endpoint
  redis_auth_token = module.database.redis_auth_token
}

module "monitoring_otel" {
  source = "./modules/monitoring_otel"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.app_subnet_ids
  app_security_group_id = module.networking.app_security_group_id
}
