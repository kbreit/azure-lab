data "tfe_organization" "org" {
    name = var.tfe_org_name
}

data "tfe_workspace" "traditional_vnet" {
    name = "azure-traditional-vnet"
    organization = data.tfe_organization.org.name
}

output "workspace_name" {
    value = data.tfe_workspace.traditional_vnet
}

# resource "tfe_workspace" "vwan" {
#     name = var.tfe_workspace_vwan_name
#     organization = data.tfe_organization.org.name
#     auto_apply = false
#     vc_repo {

#     }
# }