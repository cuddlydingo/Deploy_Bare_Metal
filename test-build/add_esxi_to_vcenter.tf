# template
# resource "terraform_data" "name_of_action" {
#   provisioner "local-exec" {
#     interpreter = ["PowerShell", "-Command"]
#     working_dir = "C:\\local_dir\\path\\test-build"
#     command     = <<-EOC

#         EOC
#   }
#   depends_on = []
# }

# Add Provisioned ESXi to vCenter
resource "terraform_data" "add_esxi_to_vcenter" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "C:\\local_dir\\path\\test-build"
    command     = <<-EOC
    Connect-VIServer -Server ${var.vcenter_ip} -User ${var.vcenter_user_eqxloc3} -Password ${var.vcenter_pw_eqxloc3};
    Start-Sleep -Seconds 30;
    Add-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -Location ${var.cluster_name} -User root -Password ${var.esxi_plain_pw} -Force;
    Start-Sleep -Seconds 30;
    Set-VMHost -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -State Maintenance -Confirm:$false;
    Start-Sleep -Seconds 30;
    Disconnect-VIServer * -Force -Confirm:$false;
    EOC
  }
  depends_on = [time_sleep.pause_after_vlan]
}

# # Configure Network Interfaces on ESXi in vCenter
resource "terraform_data" "add_mgmt_vds_to_esxi" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "C:\\local_dir\\path\\test-build"
    command     = <<-EOC
    Connect-VIServer -Server ${var.vcenter_ip} -User ${var.vcenter_user_eqxloc3} -Password ${var.vcenter_pw_eqxloc3};
    Start-Sleep -Seconds 30;
    $vmhost = Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn};
    Get-VDSwitch -Name ${var.vds_mgmt} | Add-VDSwitchVMHost -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn};
    Start-Sleep -Seconds 30;
    $vmnic4 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic4;
    $vmk0 = Get-VMHostNetworkAdapter -VMHost $vmhost -Name vmk0;
    Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch ${var.vds_mgmt} -VirtualNicPortgroup ${var.vds_mgmt_portgroup} -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic4 -Confirm:$false;
    Start-Sleep -Seconds 30;
    $vmhost | Get-VMHostNetworkAdapter -Physical -Name "vmnic2" | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false;
    Start-Sleep -Seconds 30;
    $vmnic2 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic2;
    Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch ${var.vds_mgmt} -VirtualNicPortgroup ${var.vds_mgmt_portgroup} -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic2 -Confirm:$false;
    Start-Sleep -Seconds 30;
    $vmnic3 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic3;
    Get-VDSwitch -Name ${var.vds_storage_1} | Add-VDSwitchVMHost -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn};
    Start-Sleep -Seconds 30;
    Get-VDSwitch -Name ${var.vds_storage_1} | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic3 -Confirm:$false;
    Start-Sleep -Seconds 30;
    $VDSwitch_StorageA = Get-VDSwitch -VMHost $vmhost -Name ${var.vds_storage_1};
    New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup ${var.vds_storage_1_portgroup} -VirtualSwitch $VDSwitch_StorageA -Mtu 9000 -IP ${infoblox_ip_allocation.esxi_storage_ip_1.allocated_ipv4_addr} -SubnetMask ${var.esxi_storage_subnet};
    Start-Sleep -Seconds 30;
    $vmnic4 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic4;
    $VDSwitch_vMotion = Get-VDSwitch -VMHost $vmhost -Name ${var.vds_vmotion};
    New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup ${var.vds_vmotion_portgroup} -VirtualSwitch $VDSwitch_vMotion -VMotionEnabled:$true -IP ${infoblox_ip_allocation.esxi_vmotion_ip.allocated_ipv4_addr} -SubnetMask ${var.esxi_vmotion_subnet};
    Start-Sleep -Seconds 30;
    $vmnic5 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic5;
    Get-VDSwitch -Name ${var.vds_storage_2} | Add-VDSwitchVMHost -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn};
    Start-Sleep -Seconds 30;
    Get-VDSwitch -Name ${var.vds_storage_2} | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic5 -Confirm:$false;
    Start-Sleep -Seconds 30;
    $VDSwitch_StorageB = Get-VDSwitch -VMHost $vmhost -Name ${var.vds_storage_2};
    New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup ${var.vds_storage_2_portgroup} -VirtualSwitch $VDSwitch_StorageB -Mtu 9000 -IP ${infoblox_ip_allocation.esxi_storage_ip_2.allocated_ipv4_addr} -SubnetMask ${var.esxi_storage_subnet};
    Start-Sleep -Seconds 30;
    Disconnect-VIServer * -Force -Confirm:$false;
    EOC
  }
  depends_on = [terraform_data.add_esxi_to_vcenter]
}

# Adding Storage Adapters for iSCSI
resource "terraform_data" "add_iscsi_to_esxi" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "C:\\local_dir\\path\\test-build"
    command     = <<-EOC
    Connect-VIServer -Server ${var.vcenter_ip} -User ${var.vcenter_user_eqxloc3} -Password ${var.vcenter_pw_eqxloc3};
    Start-Sleep -Seconds 30;
    Get-VMHostStorage -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Set-VMHostStorage -SoftwareIScsiEnabled $True;
    Start-Sleep -Seconds 30;
    $iScsiHBA = Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-VMHostHba -Type IScsi -Device "vmhba64";
    $iScsiHBA | New-IScsiHbaTarget -Address ${var.loc3_iscsi_dynamicdiscovery_ip_1} -Port ${var.port_value};
    Start-Sleep -Seconds 30;
    $iScsiHBA | New-IScsiHbaTarget -Address ${var.loc3_iscsi_dynamicdiscovery_ip_2} -Port ${var.port_value};
    Start-Sleep -Seconds 30;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-VMHostStorage -RescanAllHba -RescanVmfs;
    Start-Sleep -Seconds 60;
    Disconnect-VIServer * -Force -Confirm:$false;
    EOC 
  }
  depends_on = [terraform_data.add_mgmt_vds_to_esxi]
}

# Adding NTP Server and Apply Advanced Settings
resource "terraform_data" "add_adv_settings_to_esxi" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "C:\\local_dir\\path\\test-build"
    command     = <<-EOC
    Connect-VIServer -Server ${var.vcenter_ip} -User ${var.vcenter_user_eqxloc3} -Password ${var.vcenter_pw_eqxloc3};
    Start-Sleep -Seconds 30;
    Add-VMHostNtpServer -NtpServer ${var.esxi_ntp} -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -Confirm:$false -Verbose;
    Get-VMHostService -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Where-Object{$_.Key -eq "ntpd"} | Set-VMHostService -Policy "on" -Confirm:$false -Verbose;
    Get-VMHostService -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Where-Object{$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name 'Net.TcpipHeapMax' | Set-AdvancedSetting -Value '1536' -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name 'Net.TcpipHeapSize' | Set-AdvancedSetting -Value '32' -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigationIntraVM" | Set-AdvancedSetting -Value "false" -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name "UserVars.SuppressHyperthreadWarning" | Set-AdvancedSetting -Value "0" -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreading" | Set-AdvancedSetting -Value "true" -Confirm:$false -Verbose;
    Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigation" | Set-AdvancedSetting -Value "true" -Confirm:$false -Verbose;
    Get-VMHostFirewallException -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -Name "vSAN Clustering Service" | Set-VMHostFirewallException -Enabled:$True -Verbose;
    Get-VMHostFirewallException -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -Name "vSAN Transport" | Set-VMHostFirewallException -Enabled:$True -Verbose;
    Disconnect-VIServer * -Force -Confirm:$false;
    EOC
  }
  depends_on = [terraform_data.add_iscsi_to_esxi]
}

# Apply License Key and ESXi Update Baseline
resource "terraform_data" "apply_update_baseline_to_esxi" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    working_dir = "C:\\local_dir\\path\\test-build"
    command     = <<-EOC
    Connect-VIServer -Server ${var.vcenter_ip} -User ${var.vcenter_user_eqxloc3} -Password ${var.vcenter_pw_eqxloc3};
    Start-Sleep -Seconds 30;
    $vmhost = Get-VMHost -Name ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn};
    Set-VMHost -VMHost ${infoblox_ip_allocation.esxi_mgmt_ip.fqdn} -LicenseKey ${var.esxi_v8_licensekey} -Confirm:$false;
    Start-Sleep -Seconds 30;
    $baseline_iso = Get-Baseline -Name "${var.esxi_v8_baseline_iso}";
    Add-EntityBaseline -Baseline $baseline_iso -Entity $vmhost -Confirm:$false;
    Start-Sleep -Seconds 30;
    $baseline_patches = Get-Baseline -Name "${var.esxi_v8_baseline_patches}";
    Add-EntityBaseline -Baseline $baseline_patches -Entity $vmhost -Confirm:$false;
    Start-Sleep -Seconds 30;
    Update-Entity -Baseline $baseline_iso -Entity $vmhost -Confirm:$false -ErrorAction SilentlyContinue;
    Start-Sleep -Seconds 600;
    Update-Entity -Baseline $baseline_patches -Entity $vmhost -Confirm:$false -ErrorAction SilentlyContinue;
    Start-Sleep -Seconds 600;
    Disconnect-VIServer * -Force -Confirm:$false;
    EOC
  }
  depends_on = [terraform_data.add_adv_settings_to_esxi]
}
