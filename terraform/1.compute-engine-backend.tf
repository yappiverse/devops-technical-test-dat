module "compute_backend" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  service_name      = "backend"
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.app_subnet_ids
  security_group_id = module.networking.app_security_group_id
  instance_type     = var.backend_instance_type

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  target_port       = 8000
  health_check_path = "/api/health"

  alb_listener_arn = module.networking.alb_listener_arn
  path_patterns    = ["/api/*"]
  priority         = 10

  user_data_template = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
  EOF
}
