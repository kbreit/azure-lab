variable "azure_rg_name" {
  type = string
  default = "kbreit-rg"
}

variable "azure_rg_region" {
  type = string
  default="centralus"
}

variable "azure_vnet_address_spaces" {
  type = list(string)
  default = [
    "10.2.0.0/16"
  ]
}

variable "azure_vnet_subnets" {
  type = list(string)
  default = [
    "10.2.1.0/24"
  ]
}

variable "azure_subnet_names" {
  type = list(string)
  default = [
    "subnet1"
  ]
}

variable "azure_vnet_name" {
  type = string
  default = "kbreit-default"
}
