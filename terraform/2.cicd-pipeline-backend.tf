module "cicd_backend" {
  source = "./modules/cicd_pipeline"

  project_name            = var.project_name
  environment             = var.environment
  service_name            = "backend"
  github_repository       = var.backend_repo
  github_branch           = var.github_branch
  codestar_connection_arn = var.codestar_connection_arn
  asg_name                = module.compute_backend.asg_name
  buildspec_path          = "buildspec.yml"
}
