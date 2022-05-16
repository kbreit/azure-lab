data "tfe_organization" "org" {
    name = var.tfe_org_name
}

# resource "tfe_oauth_client" "github_client" {
#     name = "github-oauth-client"
#     organization = data.tfe_organization.org.name
#     api_url = "https://api.github.com"
#     http_url = "https://github.com"
#     oauth_token = var.github_oauth_token
#     service_provider = "github"
# }

resource "tfe_workspace" "vwan" {
    name = var.tfe_workspace_vwan_name
    organization = data.tfe_organization.org.name
    auto_apply = false
    working_directory = "vwan"
    vcs_repo {
        branch = ""
        identifier = "kbreit/azure-lab"
        ingress_submodules = false
        oauth_token_id = var.github_oauth_token_id
    }
}
