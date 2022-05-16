variable "azure_rg_name" {
  type = string
  default = "kbreit-rg"
}

variable "azure_rg_region" {
  type = string
  default="centralus"
}

variable "azure_vnet_lz_address_spaces" {
  type = list(string)
  default = [
    "10.2.0.0/16"
  ]
}

variable "azure_vnet_lz_subnets" {
  type = list(string)
  default = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24",
    "10.2.4.0/24",
  ]
}

variable "azure_lz_subnet_names" {
  type = list(string)
  default = [
    "subnet1",
    "GatewaySubnet",
    "AzureBastionSubnet",
    "AzureFirewallSubnet",
  ]
}

variable "azure_vnet_lz_names" {
  type = string
  default = "kbreit-default"
}

variable "azure_vnet_app_address_spaces" {
  type = list(string)
  default = [
    "10.3.0.0/16"
  ]
}

variable "azure_vnet_app_subnets" {
  type = list(string)
  default = [
    "10.3.1.0/24"
  ]
}

variable "azure_app_subnet_names" {
  type = list(string)
  default = ["web"]
}

variable "azure_vnet_app_names" {
  type = string
  default = "kbreit-app"
}

variable "azure_common_subnet_names" {
  type = list(string)
  default = [
    "common"
  ]
}

variable "azure_vnet_common_address_spaces" {
  type = list(string)
  default = [
    "10.4.0.0/16"
  ]
}

variable "azure_vnet_common_subnets" {
  type = list(string)
  default = [
    "10.4.1.0/24"
  ]
}

variable "azure_vnet_common_names" {
  type = string
  default = "kbreit-common"
}

variable "VPN_SECRET" {
  type = string
}

variable "vm_username" {
  type = string
  default = "kbreit"
}

variable "vm_distribution" {
  type = string
  default = "18.04-LTS"
}

variable "vm_size" {
  type = string
  default = "Standard_B1ls"
}

variable "vm_password" {
  type = string
}

variable "nsg_default_sap" {
  type = list(string)
  default = [
    "73.22.172.87/32"
  ]
}

variable "nsg_default_dap" {
  type = list(string)
  default = [
    "10.2.1.0/24"
  ]
}
