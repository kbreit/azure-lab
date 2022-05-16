variable "tfe_org_name" {
    type = string
    default = "kbreit"
}

variable "tfe_workspace_vwan_name" {
    type = string
    default = "azure-vwan"
}

variable = "github_oauth_token" {
    type = string
    sensitive = true
}
