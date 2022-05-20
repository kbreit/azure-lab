variable "tfe_org_name" {
    type = string
    default = "kbreit"
}

variable "tfe_workspace_vwan_name" {
    type = string
    default = "azure-vwan"
}

variable "tfe_workspace_bgp_name" {
    type = string
    default = "azure-vpn-bgp"
}

variable "github_oauth_token_id" {
    type = string
    sensitive = true
}

variable "tfe_workspace_vault_name" {
    type = string
    default = "hcp-vault"
}
