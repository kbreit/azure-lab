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
