# # Provision ESXi Server on EQX Metal
# resource "equinix_metal_device" "esxi" {
#   depends_on = [
#     local_file.esxi_csv_file,
#     infoblox_ip_allocation.esxi_mgmt_ip,
#     infoblox_ip_allocation.esxi_storage_ip_1,
#     infoblox_ip_allocation.esxi_storage_ip_2,
#     infoblox_ip_allocation.esxi_vmotion_ip
#   ]
#   for_each         = infoblox_ip_allocation.esxi_mgmt_ip
#   operating_system = var.esxi_version
#   plan             = var.esxi_size
#   project_id       = var.project_id
#   billing_cycle    = var.billing_cycle
#   # To make EQX servers deploy "on demand" rather than use "reserved" instances, comment out the "hardware_reservation_id" line, below
#   hardware_reservation_id = "next-available"
#   metro                   = var.metro
#   hostname                = each.value.fqdn
#   ip_address {
#     type = "private_ipv4"
#   }
#   timeouts {
#     create = "60m"
#   }
#   # Allow changes to these attributes without destroying and recreating the ESXi
#   behavior {
#     allow_changes = [
#       "custom_data",
#       "user_data"
#     ]
#   }
#   custom_data = jsonencode({
#     sshd = {
#       enabled = true
#       pwauth  = true
#     }
#     rootpwcrypt = var.esxi_pw
#     esxishell = {
#       enabled = true
#     }
#     kickstart = {
#       firstboot_shell       = "/bin/sh -C"
#       firstboot_shell_cmd   = <<EOT
# sed -i '/^exit*/i /vmfs/volumes/datastore1/configpost.sh' /etc/rc.local.d/local.sh;
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
# touch /vmfs/volumes/datastore1/configpost.sh;
# chmod 755 /vmfs/volumes/datastore1/configpost.sh;
# echo '#!/bin/sh' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli network ip dns server add --server=${var.esxi_dns}' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli network ip dns search add --domain="${var.esxi_domain},${var.esxi_searchdomain}"' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-advcfg -s ${each.value.fqdn} /Misc/hostname' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli system hostname set -H=${each.value.fqdn}' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli system hostname set -f=${each.value.fqdn}' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli system ntp set -s=${var.esxi_ntp} >> /etc/ntp.conf' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli system ntp set -e=yes' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-vswitch -p "Management Network" -v ${var.esxi_mgmtvlan} vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-vswitch -p "VM Network" -v ${var.esxi_mgmtvlan} vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-vmknic -d "Private Network"' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-vswitch -D "Private Network" vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcli network ip interface ipv4 set -i vmk0 -I ${each.value.allocated_ipv4_addr} -N ${var.esxi_mgmt_subnet} -g ${var.esxi_gateway} -t static' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'esxcfg-route ${var.esxi_gateway}' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'localcli system module parameters set -m tcpip4 -p ipv6=0' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'cd /etc/vmware/ssl' >> /vmfs/volumes/datastore1/configpost.sh;
# echo '/sbin/generate-certificates' >> /vmfs/volumes/datastore1/configpost.sh;
# echo '/etc/init.d/hostd restart && /etc/init.d/vpxa restart' >> /vmfs/volumes/datastore1/configpost.sh;
# echo 'sed -i '/configpost.sh/d' /etc/rc.local.d/local.sh' >> /vmfs/volumes/datastore1/configpost.sh
# EOT
#       postinstall_shell     = "/bin/sh -C"
#       postinstall_shell_cmd = ""
#     }
#   })
# }

# # Create Time_Sleep Event to Delay Resource Creation 
# # Allows kickstart file and server reboot to complete before Terraform moves on with network config
# resource "time_sleep" "reboot_after_provisioning" {
#   create_duration = "5m"
#   depends_on      = [equinix_metal_device.esxi]
# }

# # Assign VLANs to Layer 2 Physical NetWork Adapters (eth0/eth1/eth2/eth3)
# resource "equinix_metal_port" "eth0" {
#   for_each = equinix_metal_device.esxi
#   port_id  = [for port in each.value.ports : port.id if port.name == "eth0"][0]
#   bonded   = false
#   vlan_ids = var.vlan_id_loc3_res_eth_even
#   depends_on = [
#     time_sleep.reboot_after_provisioning
#   ]
#   timeouts {
#     create = "15m"
#     update = "15m"
#     delete = "15m"
#   }
# }

# resource "equinix_metal_port" "eth1" {
#   for_each = equinix_metal_device.esxi
#   port_id  = [for port in each.value.ports : port.id if port.name == "eth1"][0]
#   bonded   = false
#   vlan_ids = var.vlan_id_loc3_res_eth_odd
#   depends_on = [
#     time_sleep.reboot_after_provisioning
#   ]
#   timeouts {
#     create = "15m"
#     update = "15m"
#     delete = "15m"
#   }
# }

# resource "equinix_metal_port" "eth2" {
#   for_each = equinix_metal_device.esxi
#   port_id  = [for port in each.value.ports : port.id if port.name == "eth2"][0]
#   bonded   = false
#   vlan_ids = var.vlan_id_loc3_res_eth_even
#   depends_on = [
#     time_sleep.reboot_after_provisioning
#   ]
#   timeouts {
#     create = "15m"
#     update = "15m"
#     delete = "15m"
#   }
# }

# resource "equinix_metal_port" "eth3" {
#   for_each = equinix_metal_device.esxi
#   port_id  = [for port in each.value.ports : port.id if port.name == "eth3"][0]
#   bonded   = false
#   vlan_ids = var.vlan_id_loc3_res_eth_odd
#   depends_on = [
#     time_sleep.reboot_after_provisioning
#   ]
#   timeouts {
#     create = "15m"
#     update = "15m"
#     delete = "15m"
#   }
# }

# # Create wait period for previous VLAN setup to complete, before Powershell begins
# resource "time_sleep" "pause_after_vlan" {
#   create_duration = "2m"
#   depends_on = [
#     equinix_metal_device.esxi,
#     equinix_metal_port.eth0,
#     equinix_metal_port.eth1,
#     equinix_metal_port.eth2,
#     equinix_metal_port.eth3
#   ]
# }
