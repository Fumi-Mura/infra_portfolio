module "organizations" {
  source = "../../modules/organizations"
}

module "identity_center" {
  source = "../../modules/identity_center"
  env    = local.env
}
