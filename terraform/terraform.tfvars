aws_region          = "ap-southeast-1"
project_name        = "laravel-vue-prod"
environment         = "prod"
vpc_cidr            = "10.30.0.0/16"
availability_zones  = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24"]
app_subnet_cidrs    = ["10.30.11.0/24", "10.30.12.0/24"]
data_subnet_cidrs   = ["10.30.21.0/24", "10.30.22.0/24"]

db_instance_class        = "db.r6g.large"
db_multi_az              = true
redis_node_type          = "cache.t4g.medium"
redis_num_cache_clusters = 2

backend_instance_type  = "c6g.large"
frontend_instance_type = "t4g.medium"
