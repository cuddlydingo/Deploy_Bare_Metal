# data "terraform_remote_state" "beehive" {
#   backend = "s3"
#   config = {
#     bucket = "${var.s3_bucket}"
#     key    = "example.com/${var.ci_commit_ref_name}/${var.ci_project_dir}/${var.gitlab_project_path}/beehive/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# Get the Project's MGMT/Native VLAN ID
data "equinix_metal_vlan" "vlan" {
  metro      = var.metro
  project_id = var.project_id
  vxlan      = var.esxi_mgmtvlan
}

data "equinix_metal_device" "esxi" {
  project_id = var.project_id
  hostname   = equinix_metal_device.esxi.hostname
  depends_on = [terraform_data.apply_update_baseline_to_esxi]
}

# not all these columns may be necessary, need to check for extraneous headers
locals {
  csv_data = <<-CSV
      esxi_hostname,esxi_pw,esxi_mgmt_ip,esxi_mgmt_subnet,esxi_vmotion_ip,esxi_vmotion_subnet,esxi_storage_ip_1_fqdn,esxi_storage_ip_1,esxi_storage_ip_1_subnet,esxi_storage_ip_2_fqdn,esxi_storage_ip_2,esxi_storage_ip_2_subnet,esxi_dns,esxi_searchdomain,esxi_ntp,esxi_default_rootpw
      ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn},${var.esxi_pw},${infoblox_ip_allocation.esxi_mgmt_ip.allocated_ipv4_addr},${var.esxi_mgmt_subnet},${infoblox_ip_allocation.esxi_vmotion_ip.allocated_ipv4_addr},${var.esxi_vmotion_subnet},${infoblox_ip_allocation.esxi_storage_ip_1.fqdn},${infoblox_ip_allocation.esxi_storage_ip_1.allocated_ipv4_addr},${var.esxi_storage_subnet},${infoblox_ip_allocation.esxi_storage_ip_2.fqdn},${infoblox_ip_allocation.esxi_storage_ip_2.allocated_ipv4_addr},${var.esxi_storage_subnet},${var.esxi_dns},${var.esxi_searchdomain},${var.esxi_ntp},${data.equinix_metal_device.esxi.root_password}
    CSV

  instances  = csvdecode(local.csv_data)
  depends_on = [data.equinix_metal_device.esxi]
}

resource "local_file" "csv_output" {
  filename   = "terraform_esxi_data.csv"
  content    = local.csv_data
  depends_on = [local.csv_data]
}
