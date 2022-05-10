provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azurerm_resource_group" {
  name = var.azure_rg_name
  location = var.azure_rg_region

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_default" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  address_space = var.azure_vnet_lz_address_spaces
  vnet_name = var.azure_vnet_lz_names
  subnet_prefixes = var.azure_vnet_lz_subnets
  subnet_names = var.azure_lz_subnet_names

  nsg_ids = {
    subnet1 = module.default-nsg.network_security_group_id
  }

  route_tables_ids = {
    subnet1 = azurerm_route_table.firewall_table.id
  }

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_app" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name =  azurerm_resource_group.azurerm_resource_group.name
  address_space = var.azure_vnet_app_address_spaces
  vnet_name = var.azure_vnet_app_names
  subnet_prefixes = var.azure_vnet_app_subnets
  subnet_names = var.azure_app_subnet_names

  route_tables_ids = {
    web = azurerm_route_table.app_table.id
  }

  nsg_ids = {
    web = module.default-nsg.network_security_group_id
  }

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_common" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name =  azurerm_resource_group.azurerm_resource_group.name
  address_space = var.azure_vnet_common_address_spaces
  vnet_name = var.azure_vnet_common_names
  subnet_prefixes = var.azure_vnet_common_subnets
  subnet_names = var.azure_common_subnet_names

  route_tables_ids = {
    common = azurerm_route_table.common-table.id
  }

  nsg_ids = {
    common = module.default-nsg.network_security_group_id
  }

  tags = {
    owner = "Kevin Breit"
  }
}

resource "azurerm_virtual_network_peering" "default_to_app" {
  name = "default-to-app"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_default.vnet_name
  remote_virtual_network_id = module.vnet_app.vnet_id
  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "default_to_common" {
  name = "default-to-common"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_default.vnet_name
  remote_virtual_network_id = module.vnet_common.vnet_id
  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "common_to_default" {
  name = "common-to-default"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_common.vnet_name
  remote_virtual_network_id = module.vnet_default.vnet_id
  use_remote_gateways = true
}

resource "azurerm_virtual_network_peering" "app_to_default" {
  name = "app-to-default"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  virtual_network_name =  module.vnet_app.vnet_name
  remote_virtual_network_id = module.vnet_default.vnet_id
  use_remote_gateways = true
}

resource "azurerm_public_ip" "vpn_gateway_ip" {
  name = "vpn-gateway-ip"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name = "vpn-gateway"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = false
  sku = "Basic"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_default.vnet_subnets[1]
  }
}

resource "azurerm_local_network_gateway" "ep_gateway" {
  name = "ep-gateway"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location = azurerm_resource_group.azurerm_resource_group.location
  gateway_address = "34.138.95.11"
  address_space = [
    "10.207.0.0/24"
  ]
}

resource "azurerm_virtual_network_gateway_connection" "ep_vpn_connection" {
  name = "ep-connection"
  location = azurerm_resource_group.azurerm_resource_group.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name

  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id = azurerm_local_network_gateway.ep_gateway.id

  shared_key = var.VPN_SECRET
}

resource "azurerm_network_interface" "default_vnet_vm_intf" {
  name = "default-vm-intf"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_default.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "default_vnet_vm" {
  name = "kbreit-default-vnet-vm"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.default_vnet_vm_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_distribution
    version   = "latest"
  }
}

resource "azurerm_network_interface" "app_vnet_vm_intf" {
  name = "app-vm-intf"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_app.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app_vnet_vm" {
  name = "kbreit-app-vnet-vm"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.app_vnet_vm_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_distribution
    version   = "latest"
  }
}

resource "azurerm_network_interface" "common_vnet_vm_intf" {
  name = "common-vm-intf"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_common.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "common_vnet_vm" {
  name = "kbreit-common-vnet-vm"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.common_vnet_vm_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_distribution
    version   = "latest"
  }
}

resource "azurerm_public_ip" "bastion_pup" {
  name = "kbreit-bastion-pup"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = "kbreit-bastion"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  tunneling_enabled = true
  sku = "Standard"

  ip_configuration {
    name = "configuration"
    subnet_id = module.vnet_default.vnet_subnets[2]
    public_ip_address_id = azurerm_public_ip.bastion_pup.id
  }
}

module "default-nsg" {
  source = "Azure/network-security-group/azurerm"
  version = "3.6.0"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  source_address_prefixes = var.nsg_default_sap
  destination_address_prefixes = var.nsg_default_dap
  security_group_name = "default-nsg"

  custom_rules = [
    {
      name                   = "home-ssh"
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "22"
      source_address_prefix  = "73.22.172.87/32"
      description            = "SSH from Kevin's House"
    }
  ]
}

resource "azurerm_public_ip" "firewall_pup" {
  name = "kbreit-firewall-pup"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  allocation_method = "Static"
  sku = "Standard"
}


resource "azurerm_firewall" "hub_firewall" {
  name = "hub-firewall"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"
  ip_configuration {
    name = "configuration"
    subnet_id = module.vnet_default.vnet_subnets[3]
    public_ip_address_id = azurerm_public_ip.firewall_pup.id
  }
}

resource "azurerm_firewall_policy" "default_policy" {
  name = "default-policy"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location
}

resource "azurerm_firewall_network_rule_collection" "east_west_network_collection" {
  name = "east-west-collection"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  azure_firewall_name = azurerm_firewall.hub_firewall.name
  priority = 500
  action = "Allow"

  rule { 
    name = "icmp"
    source_addresses = [
      "10.3.0.0/24",
      "10.4.0.0/24",
    ]

    destination_addresses = [
      "10.3.0.0/24",
      "10.4.0.0/24",
    ]

    destination_ports = [
      "any",
    ]

    protocols = [
      "ICMP",
    ]
  }
}

resource "azurerm_route_table" "firewall_table" {
  name = "firewall-table"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location

  route {
    name = "firewall-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_route_table" "common-table" {
  name = "common-table"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location

  route {
    name = "app-route"
    address_prefix = var.azure_vnet_app_address_spaces[0]
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_route_table" "app_table" {
  name = "app-table"
  resource_group_name = azurerm_resource_group.azurerm_resource_group.name
  location            = azurerm_resource_group.azurerm_resource_group.location

  route {
    name = "common-route"
    address_prefix = var.azure_vnet_common_address_spaces[0]
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }
}
