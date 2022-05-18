terraform {
  required_providers {
    tfe = {
      version = "~> 0.30.2"
    }
  }
}

data "tfe_organization" "kbreit" {
    name = var.tfe_org_name
}
