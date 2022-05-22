resource "azurerm_resource_group" "kbreit_vpn_bgp_central" {
  name = "kbreit-vpn-bgp-central"
  location = "centralus"

  tags = {
    owner = "Kevin Breit"
  }
}

module "vnet_central" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  address_space = ["10.3.0.0/16"]
  vnet_name = "vnet-central"
  subnet_prefixes = ["10.3.1.0/24"]
  subnet_names = ["GatewaySubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_central
  ]
}

resource "azurerm_public_ip" "vpn_gateway_ip_central" {
  name = "vpn-gateway-ip-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway_central" {
  name = "vpn-gateway-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name

  type = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp = true
  sku = "VpnGw2"
  generation = "Generation2"

  ip_configuration {
    name = "vpnGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip_central.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_central.vnet_subnets[0]
  }

  bgp_settings {
      asn = 65533
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_central_to_east" {
  name = "connection-to-east"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  type = "Vnet2Vnet"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_central.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_east.id
  enable_bgp = true

  shared_key = var.vpn_shared_key
}

module "vnet_vendor" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  address_space = ["10.5.0.0/16"]
  vnet_name = "vnet-vendor"
  subnet_prefixes = ["10.5.1.0/24"]
  subnet_names = ["AppSubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_central
  ]
}

resource "azurerm_virtual_network_peering" "central_to_vendor" {
  name = "central-to-vendor"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  virtual_network_name = module.vnet_central.vnet_name
  remote_virtual_network_id = module.vnet_vendor.vnet_id

  allow_forwarded_traffic = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vendor_to_central" {
  name = "central-to-vendor"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  virtual_network_name = module.vnet_vendor.vnet_name
  remote_virtual_network_id = module.vnet_central.vnet_id

  allow_gateway_transit = true
  allow_forwarded_traffic = true
  allow_virtual_network_access = true
}

resource "azurerm_linux_virtual_machine" "central_vnet_vm" {
  name = "kbreit-central-vnet-vm"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central
  location            = azurerm_resource_group.kbreit_vpn_bgp_central.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.central_vnet_vm_intf.id,
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

resource "azurerm_network_interface" "central_vnet_vm_intf" {
  name = "central-vm-intf"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  location            = azurerm_resource_group.kbreit_vpn_bgp_central.location
  ip_configuration {
    name = "internal"
    subnet_id = module.vnet_central.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}
