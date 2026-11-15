module "compute_frontend" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  service_name      = "frontend"
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.app_subnet_ids
  security_group_id = module.networking.frontend_security_group_id
  instance_type     = var.frontend_instance_type

  min_size         = 2
  max_size         = 6
  desired_capacity = 2

  target_port       = 80
  health_check_path = "/"

  alb_listener_arn = module.networking.alb_listener_arn
  path_patterns    = ["/*"]
  priority         = 20

  app_secrets_arn          = module.etc.app_secrets_arn
  ssm_frontend_api_url_arn = module.etc.ssm_frontend_api_url_arn
  uploads_bucket_arn       = module.etc.uploads_bucket_arn
  appconfig_application_id = module.etc.appconfig_application_id

  user_data_template = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
  EOF
}
