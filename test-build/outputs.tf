output "device_name" {
  description = "Name of the Metal device"
  value       = equinix_metal_device.esxi.hostname
}

output "device_fqdn" {
  description = "FQDN of the Metal Device"
  value       = join("", [var.esxi_name, ".", var.esxi_domain])
}

output "vmk0_ip" {
  description = "IP Address set on vmk0"
  value       = infoblox_ip_allocation.esxi_mgmt_ip.allocated_ipv4_addr
}

output "storage_ip_1" {
  description = "IP Address for storage IP 1 of 2"
  value       = infoblox_ip_allocation.esxi_storage_ip_1.allocated_ipv4_addr
}

output "storage_ip_2" {
  description = "IP Address for storage IP 2 of 2"
  value       = infoblox_ip_allocation.esxi_storage_ip_2.allocated_ipv4_addr
}

output "device_id" {
  description = "Metal Device ID"
  value       = equinix_metal_device.esxi.id
}

output "esxi_mgmt_network_eqxloc3" {
  value       = data.infoblox_ipv4_network.esxi_mgmt_eqxloc3
  description = "The VLAN for EQX-LOC3 ESXi MGMT IPv4 Addresses"
}

output "esxi_storage_network_eqxloc3" {
  value       = data.infoblox_ipv4_network.esxi_storage_eqxloc3
  description = "The Layer 2 Storage IPv4 network for ESXi in EQX-LOC3"
}

output "csv_test_data" {
  value     = local.csv_data
  sensitive = true
}
