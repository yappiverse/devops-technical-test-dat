module "cicd_frontend" {
  source = "./modules/cicd_pipeline"

  project_name            = var.project_name
  environment             = var.environment
  service_name            = "frontend"
  github_repository       = var.frontend_repo
  github_branch           = var.github_branch
  codestar_connection_arn = var.codestar_connection_arn
  asg_name                = module.compute_frontend.asg_name
  buildspec_path          = "buildspec.yml"
}
