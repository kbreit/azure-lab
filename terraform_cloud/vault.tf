data "tfe_organization" "kbreit" {
    name = var.tfe_org_name
}

resource "tfe_workspace" "vault" {
    name = var.tfe_workspace_vault_name
    organization = data.tfe_organization.kbreit.name
    auto_apply = true
    vcs_repo {
        branch = ""
        identifier = "kbreit/vault-lab"
        ingress_submodules = false
        oauth_token_id = var.github_oauth_token_id
    }
}
