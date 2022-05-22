resource "azurerm_resource_group" "kbreit_vpn_bgp_east" {
  name = "kbreit-vpn-bgp-east"
  location = "eastus"

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_east" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  address_space = ["10.4.0.0/16"]
  vnet_name = "vnet-east"
  subnet_prefixes = ["10.4.1.0/24", "10.4.2.0/24"]
  subnet_names = ["GatewaySubnet", "VMSubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_east
  ]
}

resource "azurerm_public_ip" "vpn_gateway_ip_east" {
  name = "vpn-gateway-ip-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway_east" {
  name = "vpn-gateway-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = true
  sku = "VpnGw2"
  generation = "Generation2"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip_east.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_east.vnet_subnets[0]
  }

  bgp_settings {
      asn = 65534
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_east_to_central" {
  name = "connection-to-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_east.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  type = "Vnet2Vnet"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_east.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_central.id
  enable_bgp = true  

  shared_key = var.vpn_shared_key
}

resource "azurerm_linux_virtual_machine" "east_vnet_vm" {
  name = "kbreit-east-vnet-vm"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  location            = azurerm_resource_group.kbreit_vpn_bgp_east.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.east_vnet_vm_intf.id,
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

resource "azurerm_network_interface" "east_vnet_vm_intf" {
  name = "east-vm-intf"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_east.name
  location            = azurerm_resource_group.kbreit_vpn_bgp_east.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_east.vnet_subnets[1]
    private_ip_address_allocation = "Dynamic"
  }
}
