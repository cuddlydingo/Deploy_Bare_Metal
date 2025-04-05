# This PowerShell Script should ingest both the Terraform-generated CSV of ESXi data, and the necessary terraform environment variables.
# This Script will add the newly-provisioned ESXi hosts to the desired vCenter/Cluster, and apply advanced settings, license keys, and pre-defined security baselines/patches.

# Connect to vCenter
Connect-VIServer -Server $Env:env_vcenter_ip -User $Env:env_vcenter_user_eqxloc3 -Password $Env:env_vcenter_pw_eqxloc3 -Verbose


# Import CSV with Host Data.
# This script expects the CSV to contain data similar to the excerpt below:
#   Hostname, Storage_IP_1, Storage_IP_2, vMotion_IP
#   jpl-poc-phase74-401.eqx-loc3.example.com,172.10.10.10,172.10.10.11,192.168.1.5
#   jpl-poc-phase74-402.eqx-loc3.example.com,172.10.10.50,172.10.10.51,192.168.1.6
$esxi_csv_data = Import-Csv -Path "./esxi_csv_data.csv"


# Add New ESXi Hosts to vCenter, one at a time
foreach ($esxi in $esxi_csv_data) {
  Add-VMHost -Name $esxi.Hostname -Location $Env:env_cluster_name -User root -Password $Env:env_esxi_plain_pw -Confirm:$false -Force
  Set-VMHost -VMHost $esxi.Hostname -State "Maintenance" -Confirm:$false
  Start-Sleep -Seconds 30
}


# Configure Network Interfaces on ESXi in vCenter
foreach ($esxi in $esxi_csv_data) {
  # Determine if server is SuperMicro or Open19 hardware, and use block for appropriate network adapter names.  See README.md for more details.
  $hardware_platform_name = (get-esxcli -VMHost $esxi.Hostname).hardware.platform.get().VendorName
  if ($hardware_platform_name -eq "Supermicro") {
    $hardware_case = "SuperMicro"
  }
  else {
    $hardware_case = "Open19"
  }

  switch ($hardware_case) {
    "SuperMicro" {
      $vmhost = Get-VMHost -Name $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_mgmt | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      $vmnic4 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic4
      Start-Sleep -Seconds 30
      $vmk0 = Get-VMHostNetworkAdapter -VMHost $vmhost -Name vmk0
      Start-Sleep -Seconds 30
      Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $Env:env_vds_mgmt -VirtualNicPortgroup $Env:env_vds_mgmt_portgroup -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic4 -Confirm:$false
      Start-Sleep -Seconds 30
      $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic2 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
      Start-Sleep -Seconds 30
      $vmnic2 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic2
      Start-Sleep -Seconds 30
      Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $Env:env_vds_mgmt -VirtualNicPortgroup $Env:env_vds_mgmt_portgroup -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic2 -Confirm:$false
      Start-Sleep -Seconds 30
      $vmnic3 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic3
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_1 | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_1 | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic3 -Confirm:$false
      Start-Sleep -Seconds 30
      $VDSwitch_StorageA = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_storage_1
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_storage_1_portgroup -VirtualSwitch $VDSwitch_StorageA -Mtu 9000 -IP $esxi.Storage_IP_1 -SubnetMask $Env:env_esxi_storage_subnet
      Start-Sleep -Seconds 30
      $vmnic4 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic4
      Start-Sleep -Seconds 30
      $VDSwitch_vMotion = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_vmotion
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_vmotion_portgroup -VirtualSwitch $VDSwitch_vMotion -VMotionEnabled:$true -IP $esxi.vMotion_IP -SubnetMask $Env:env_esxi_vmotion_subnet
      Start-Sleep -Seconds 30
      $vmnic5 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic5
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_2 | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_2 | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic5 -Confirm:$false
      Start-Sleep -Seconds 30
      $VDSwitch_StorageB = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_storage_2
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_storage_2_portgroup -VirtualSwitch $VDSwitch_StorageB -Mtu 9000 -IP $esxi.Storage_IP_2 -SubnetMask $Env:env_esxi_storage_subnet
      Start-Sleep -Seconds 30
    }
    "Open19" {
      $vmhost = Get-VMHost -Name $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_mgmt | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      $vmnic2 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic2
      Start-Sleep -Seconds 30
      $vmk0 = Get-VMHostNetworkAdapter -VMHost $vmhost -Name vmk0
      Start-Sleep -Seconds 30
      Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $Env:env_vds_mgmt -VirtualNicPortgroup $Env:env_vds_mgmt_portgroup -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic2 -Confirm:$false
      Start-Sleep -Seconds 30
      $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic0 | Remove-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false
      Start-Sleep -Seconds 30
      $vmnic0 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic0
      Start-Sleep -Seconds 30
      Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $Env:env_vds_mgmt -VirtualNicPortgroup $Env:env_vds_mgmt_portgroup -VMHostVirtualNic $vmk0 -VMHostPhysicalNic $vmnic0 -Confirm:$false
      Start-Sleep -Seconds 30
      $vmnic1 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic1
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_1 | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_1 | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic1 -Confirm:$false
      Start-Sleep -Seconds 30
      $VDSwitch_StorageA = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_storage_1
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_storage_1_portgroup -VirtualSwitch $VDSwitch_StorageA -Mtu 9000 -IP $esxi.Storage_IP_1 -SubnetMask $Env:env_esxi_storage_subnet
      Start-Sleep -Seconds 30
      $vmnic2 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic2
      Start-Sleep -Seconds 30
      $VDSwitch_vMotion = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_vmotion
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_vmotion_portgroup -VirtualSwitch $VDSwitch_vMotion -VMotionEnabled:$true -IP $esxi.vMotion_IP -SubnetMask $Env:env_esxi_vmotion_subnet
      Start-Sleep -Seconds 30
      $vmnic3 = $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic3
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_2 | Add-VDSwitchVMHost -VMHost $esxi.Hostname
      Start-Sleep -Seconds 30
      Get-VDSwitch -Name $Env:env_vds_storage_2 | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic3 -Confirm:$false
      Start-Sleep -Seconds 30
      $VDSwitch_StorageB = Get-VDSwitch -VMHost $vmhost -Name $Env:env_vds_storage_2
      Start-Sleep -Seconds 30
      New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup $Env:env_vds_storage_2_portgroup -VirtualSwitch $VDSwitch_StorageB -Mtu 9000 -IP $esxi.Storage_IP_2 -SubnetMask $Env:env_esxi_storage_subnet
      Start-Sleep -Seconds 30
    }
  }
}


# Configure remaining advanced settings and add license keys
foreach ($esxi in $esxi_csv_data) {
  $vmhost = Get-VMHost -Name $esxi.Hostname
  Get-VMHostStorage -VMHost $vmhost | Set-VMHostStorage -SoftwareIScsiEnabled $True
  $iscsi_adapter_name = (Get-VMHost -Name $esxi.Hostname | Get-VMHostHba -Type IScsi | Where-Object { $_.Model -eq "iSCSI Software Adapter" -and $_.Status -eq "online" }).Name    # Get the iSCSI adapter name since the name might be different on some hosts
  $iScsiHBA = Get-VMHost -Name $esxi.Hostname | Get-VMHostHba -Type IScsi -Device $iscsi_adapter_name
  $iScsiHBA | New-IScsiHbaTarget -Address $Env:env_loc3_iscsi_dynamicdiscovery_ip_1 -Port $Env:env_loc3_iscsi_dynamicdiscovery_port
  $iScsiHBA | New-IScsiHbaTarget -Address $Env:env_loc3_iscsi_dynamicdiscovery_ip_2 -Port $Env:env_loc3_iscsi_dynamicdiscovery_port
  Get-VMHost -Name $vmhost | Get-VMHostStorage -RescanAllHba -RescanVmfs
  Add-VMHostNtpServer -NtpServer $Env:env_esxi_ntp -VMHost $esxi.Hostname -Confirm:$false -Verbose
  Get-VMHostService -VMHost $esxi.Hostname | Where-Object { $_.Key -eq "ntpd" } | Set-VMHostService -Policy "on" -Confirm:$false -Verbose
  Get-VMHostService -VMHost $esxi.Hostname | Where-Object { $_.Key -eq "ntpd" } | Restart-VMHostService -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name 'Net.TcpipHeapMax' | Set-AdvancedSetting -Value '1536' -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name 'Net.TcpipHeapSize' | Set-AdvancedSetting -Value '32' -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigationIntraVM" | Set-AdvancedSetting -Value "false" -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name "UserVars.SuppressHyperthreadWarning" | Set-AdvancedSetting -Value "0" -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreading" | Set-AdvancedSetting -Value "true" -Confirm:$false -Verbose
  Get-VMHost -Name $esxi.Hostname | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigation" | Set-AdvancedSetting -Value "true" -Confirm:$false -Verbose
  # Get-VMHostFirewallException -VMHost $esxi.Hostname -Name "vSAN Clustering Service" | Set-VMHostFirewallException -Enabled:$True -Verbose    # This is command is owned by a system service, and no longer configurable via PowerCLI advanced settings
  # Get-VMHostFirewallException -VMHost $esxi.Hostname -Name "vSAN Transport" | Set-VMHostFirewallException -Enabled:$True -Verbose
  Set-VMHost -VMHost $esxi.Hostname -LicenseKey $Env:env_esxi_v8_licensekey -Confirm:$false
}


# Populate .csv file for NetApp Storage Adapter IQNs, relative to each ESXi host.
# To be parsed by the netapp_storage_adder.sh script's execution, from ps_script_builder.tf
foreach ($esxi in $esxi_csv_data) {
  $iscsi_adapter_name = (Get-VMHost -Name $esxi.Hostname | Get-VMHostHba -Type IScsi | Where-Object { $_.Model -eq "iSCSI Software Adapter" -and $_.Status -eq "online" }).Name
  $esxi_iscsi_iqn = (Get-VMHost -Name $esxi.Hostname | Get-VMHostHba -Type IScsi | Where-Object { $_.Name -like $iscsi_adapter_name }).ExtensionData.IScsiName
  ForEach-Object {
    [PSCustomObject]@{
      Hostname = $esxi.Hostname
      IQN      = $esxi_iscsi_iqn
    }
  } | Export-Csv -Path "./esxi_netapp_iqn.csv" -NoTypeInformation -Append -Force
}


# Apply Security Patching and Baselines
# Baselines are defined in terraform.tfvars. You may need to confirm in VCenter if the baseline is accurate and up to date.
# Requires TCP Port 8084 from the terraform source to the vCenter
$baseline_iso = Get-Baseline -Name $Env:env_esxi_v8_baseline_iso
$baseline_patches = Get-Baseline -Name $Env:env_esxi_v8_baseline_patches

foreach ($esxi in $esxi_csv_data) {
  $vmhost = Get-VMHost -Name $esxi.Hostname
  Add-EntityBaseline -Baseline $baseline_iso -Entity $vmhost -Confirm:$false
  Add-EntityBaseline -Baseline $baseline_patches -Entity $vmhost -Confirm:$false
  Update-Entity -Baseline $baseline_iso -Entity $vmhost -Confirm:$false -ErrorAction SilentlyContinue
  Update-Entity -Baseline $baseline_patches -Entity $vmhost -Confirm:$false -ErrorAction SilentlyContinue
}

# Disconnect from vCenter
Disconnect-VIServer -Server * -Confirm:$false -Force