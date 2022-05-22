module "vnet_vendor" {
  source = "Azure/vnet/azurerm"
  version = "2.6.0"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  address_space = ["10.5.0.0/16"]
  vnet_name = "vnet-vendor"
  subnet_prefixes = ["10.5.1.0/24", "10.5.2.0/24"]
  subnet_names = ["AppSubnet", "GatewaySubnet"]

  tags = {
    owner = "Kevin Breit"
  }

  depends_on = [
    azurerm_resource_group.kbreit_vpn_bgp_central
  ]
}

resource "azurerm_virtual_network_peering" "vendor_to_central" {
  name = "vendor-to-central"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  virtual_network_name = module.vnet_vendor.vnet_name
  remote_virtual_network_id = module.vnet_central.vnet_id

  allow_gateway_transit = true
  allow_forwarded_traffic = true
  allow_virtual_network_access = true
}

resource "azurerm_public_ip" "vpn_gateway_ip_vendor" {
  name = "vpn-gateway-ip-vendor"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway_vendor" {
  name = "vpn-gateway-vendor"
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
    public_ip_address_id = azurerm_public_ip.vpn_gateway_ip_vendor.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = module.vnet_vendor.vnet_subnets[1]
  }

  bgp_settings {
      asn = 65532
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_vendor_to_central" {
  name = "connection-to-central"
  location = azurerm_resource_group.kbreit_vpn_bgp_central.location
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  type = "Vnet2Vnet"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_vendor.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway_central.id
  enable_bgp = true

  shared_key = var.vpn_shared_key
}
