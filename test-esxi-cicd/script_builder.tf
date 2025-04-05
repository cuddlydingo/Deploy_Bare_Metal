# Create .csv file containing ESXi Storage and vMotion IPv4 Addresses
# Will be imported for use with PowerShell commands to set advanced ESXi settings in vCenter
resource "local_file" "esxi_csv_file" {
  filename = "./esxi_csv_data.csv"
  depends_on = [
    infoblox_ip_allocation.esxi_mgmt_ip,
    infoblox_ip_allocation.esxi_storage_ip_1,
    infoblox_ip_allocation.esxi_storage_ip_2,
    infoblox_ip_allocation.esxi_vmotion_ip
  ]
  content = <<EOT
Hostname, Storage_IP_1, Storage_IP_2, vMotion_IP
EOT
}

# Populate CSV with required information for each ESXi to be used in ${terraform_data.add_mgmt_vds_to_esxi}
resource "terraform_data" "esxi_csv_populator" {
  for_each = equinix_metal_device.esxi
  depends_on = [
    local_file.esxi_csv_file,
    equinix_metal_device.esxi,
    time_sleep.pause_after_vlan
  ]
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "./"
    command     = <<EOC
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 300)
    "${each.value.hostname}" + "," + "${infoblox_ip_allocation.esxi_storage_ip_1[each.key].allocated_ipv4_addr}" + "," + "${infoblox_ip_allocation.esxi_storage_ip_2[each.key].allocated_ipv4_addr}" + "," + "${infoblox_ip_allocation.esxi_vmotion_ip[each.key].allocated_ipv4_addr}" | Out-File -FilePath "./esxi_csv_data.csv" -Encoding "UTF8" -Append
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 120)
EOC
  }
}

resource "terraform_data" "esxi_customizer" {
  depends_on = [terraform_data.esxi_csv_populator]
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "./"
    command     = "./adv_esxi_settings.ps1"
    environment = {
      env_cluster_name                     = var.cluster_name
      env_esxi_ntp                         = var.esxi_ntp
      env_esxi_plain_pw                    = var.esxi_plain_pw
      env_esxi_storage_subnet              = var.esxi_storage_subnet
      env_esxi_v8_baseline_iso             = var.esxi_v8_baseline_iso
      env_esxi_v8_baseline_patches         = var.esxi_v8_baseline_patches
      env_esxi_v8_licensekey               = var.esxi_v8_licensekey
      env_esxi_vmotion_subnet              = var.esxi_vmotion_subnet
      env_loc3_iscsi_dynamicdiscovery_ip_1 = var.loc3_iscsi_dynamicdiscovery_ip_1
      env_loc3_iscsi_dynamicdiscovery_ip_2 = var.loc3_iscsi_dynamicdiscovery_ip_2
      env_loc3_iscsi_dynamicdiscovery_port = var.loc3_iscsi_dynamicdiscovery_port
      env_vcenter_ip                       = var.vcenter_ip
      env_vcenter_pw_eqxloc3               = var.vcenter_pw_eqxloc3
      env_vcenter_user_eqxloc3             = var.vcenter_user_eqxloc3
      env_vds_mgmt                         = var.vds_mgmt
      env_vds_mgmt_portgroup               = var.vds_mgmt_portgroup
      env_vds_storage_1                    = var.vds_storage_1
      env_vds_storage_1_portgroup          = var.vds_storage_1_portgroup
      env_vds_storage_2                    = var.vds_storage_2
      env_vds_storage_2_portgroup          = var.vds_storage_2_portgroup
      env_vds_vmotion                      = var.vds_vmotion
      env_vds_vmotion_portgroup            = var.vds_vmotion_portgroup
    }
  }
}


resource "terraform_data" "netapp_storage_adder" {
  depends_on = [terraform_data.esxi_customizer]
  provisioner "local-exec" {
    interpreter = ["bash"]
    working_dir = "./"
    command     = "./netapp_storage_adder.sh"
  }
}


# There should be a final piece to reboot the ESXi hosts once, but leave them in Maintenance Mode.
# Any Host Profiles should be added autonomously by the parent vCenter Cluster.