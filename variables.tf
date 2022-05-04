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
    "10.2.1.0/24"
  ]
}

variable "azure_lz_subnet_names" {
  type = list(string)
  default = [
    "subnet1"
  ]
}

variable "azure_vnet_lz_name" {
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

varialbe "azure_app_subnet_names" {
  type = list(string)
  default = ["web"]
}

variable "azure_vnet_app_name" {
  type = string
  default = "kbreit-app"
}
