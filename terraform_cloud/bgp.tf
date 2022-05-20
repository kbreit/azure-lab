resource "tfe_workspace" "bgp" {
    name = var.tfe_workspace_bgp_name
    organization = data.tfe_organization.kbreit.name
    auto_apply = true
    working_directory = "bgp"
    vcs_repo {
        branch = ""
        identifier = "kbreit/azure-lab"
        ingress_submodules = false
        oauth_token_id = var.github_oauth_token_id
    }
}
