# Get InfoBlox Networks for MGMT and Storage Networks
data "infoblox_ipv4_network" "esxi_mgmt_eqxloc3" {
  filters = {
    network = "CIDR_Value"
    comment = "ESXi MGMT"
  }
}

data "infoblox_ipv4_network" "esxi_storage_eqxloc3" {
  filters = {
    network = "CIDR_Value"
    comment = "EQX-LOC3 - L2 Storage Block"
  }
}

data "infoblox_ipv4_network" "esxi_vmotion_eqxloc3" {
  filters = {
    network = "network_cidr_range"
    comment = "VMWare Vmotion EQX-LOC3"
  }
}

# ESXi build should 'depend_on' this esxi_mgmt_ip value being created
resource "infoblox_ip_allocation" "esxi_mgmt_ip" {
  for_each   = var.esxi_name_set
  fqdn       = join("", [each.value, ".", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
  ttl        = 300
}

resource "infoblox_ip_allocation" "esxi_storage_ip_1" {
  for_each   = var.esxi_name_set
  fqdn       = join("", [each.value, "-nas1.", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
}

resource "infoblox_ip_allocation" "esxi_storage_ip_2" {
  for_each   = var.esxi_name_set
  fqdn       = join("", [each.value, "-nas2.", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
}

resource "infoblox_ip_allocation" "esxi_vmotion_ip" {
  for_each   = var.esxi_name_set
  fqdn       = join("", [each.value, "-vmtn.", var.esxi_domain])
  ipv4_cidr  = "network_cidr_range"
  enable_dns = true
}
