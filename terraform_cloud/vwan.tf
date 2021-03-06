resource "tfe_workspace" "vwan" {
    name = var.tfe_workspace_vwan_name
    organization = data.tfe_organization.kbreit.name
    auto_apply = true
    working_directory = "vwan"
    vcs_repo {
        branch = ""
        identifier = "kbreit/azure-lab"
        ingress_submodules = false
        oauth_token_id = var.github_oauth_token_id
    }
}
