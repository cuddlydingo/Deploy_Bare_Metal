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

# Allocate IPv4 Address from next available in network block
resource "infoblox_ip_allocation" "esxi_mgmt_ip" {
  fqdn       = join("", [var.esxi_name, ".", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
  ttl        = 300
}

resource "infoblox_ip_allocation" "esxi_storage_ip_1" {
  fqdn       = join("", [var.esxi_name, "-nas1.", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
}

resource "infoblox_ip_allocation" "esxi_storage_ip_2" {
  fqdn       = join("", [var.esxi_name, "-nas2.", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
}

resource "infoblox_ip_allocation" "esxi_vmotion_ip" {
  fqdn       = join("", [var.esxi_name, "-vmtn.", var.esxi_domain])
  ipv4_cidr  = "CIDR_Value"
  enable_dns = true
}
