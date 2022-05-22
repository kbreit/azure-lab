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

resource "azurerm_virtual_network_peering" "vendor_to_central" {
  name = "vendor-to-central"
  resource_group_name = azurerm_resource_group.kbreit_vpn_bgp_central.name
  virtual_network_name = module.vnet_vendor.vnet_name
  remote_virtual_network_id = module.vnet_central.vnet_id

  allow_gateway_transit = true
  allow_forwarded_traffic = true
  allow_virtual_network_access = true
}
