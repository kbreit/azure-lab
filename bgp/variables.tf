variable "vpn_shared_key" {
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