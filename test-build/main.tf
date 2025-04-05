# Provision ESXi Hosts
resource "equinix_metal_device" "esxi" {
  billing_cycle           = var.billing_cycle
  hardware_reservation_id = "next-available"
  hostname                = join("", [var.esxi_name, ".", var.esxi_domain])
  metro                   = var.metro
  operating_system        = var.esxi_version
  plan                    = var.esxi_size
  project_id              = var.project_id
  ip_address {
    type = "private_ipv4"
  }
  timeouts {
    create = "60m"
  }
  # Allow changes to these attributes without destroying and recreating the ESXi
  behavior {
    allow_changes = [
      "custom_data",
      "user_data"
    ]
  }
  custom_data = jsonencode({
    sshd = {
      enabled = true
      pwauth  = true
    }
    rootpwcrypt = var.esxi_pw
    esxishell = {
      enabled = true
    }
    kickstart = {
      firstboot_shell       = "/bin/sh -C"
      firstboot_shell_cmd   = <<EOT
sed -i '/^exit*/i /vmfs/volumes/datastore1/configpost.sh' /etc/rc.local.d/local.sh;
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
touch /vmfs/volumes/datastore1/configpost.sh;
chmod 755 /vmfs/volumes/datastore1/configpost.sh;
echo '#!/bin/sh' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli network ip dns server add --server=${var.esxi_dns}' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli network ip dns search add --domain=${var.esxi_domain},${var.esxi_searchdomain}' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-advcfg -s ${var.esxi_name}.${var.esxi_domain} /Misc/hostname' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli system hostname set -H=${var.esxi_name}' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli system hostname set -f=${var.esxi_name}.${var.esxi_domain}' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli system ntp set -s=${var.esxi_ntp} >> /etc/ntp.conf' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli system ntp set -e=yes' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-vswitch -p "Management Network" -v ${var.esxi_mgmtvlan} vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-vswitch -p "VM Network" -v ${var.esxi_mgmtvlan} vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-vmknic -d "Private Network"' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-vswitch -D "Private Network" vSwitch0' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcli network ip interface ipv4 set -i vmk0 -I ${infoblox_ip_allocation.esxi_mgmt_ip.allocated_ipv4_addr} -N ${var.esxi_mgmt_subnet} -g ${var.esxi_gateway} -t static' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'esxcfg-route ${var.esxi_gateway}' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'localcli system module parameters set -m tcpip4 -p ipv6=0' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'cd /etc/vmware/ssl' >> /vmfs/volumes/datastore1/configpost.sh;
echo '/sbin/generate-certificates' >> /vmfs/volumes/datastore1/configpost.sh;
echo '/etc/init.d/hostd restart && /etc/init.d/vpxa restart' >> /vmfs/volumes/datastore1/configpost.sh;
echo 'sed -i '/configpost.sh/d' /etc/rc.local.d/local.sh' >> /vmfs/volumes/datastore1/configpost.sh
EOT
      postinstall_shell     = "/bin/sh -C"
      postinstall_shell_cmd = ""
    }
  })
}

# Create Time_Sleep Event to Delay Resource Creation
# Allows kickstart file and server reboot to complete before Terraform moves on with network config
resource "time_sleep" "reboot_after_provisioning" {
  create_duration = "5m"
  depends_on      = [equinix_metal_device.esxi]
}

# Assign VLANs to Ethernet Adapters
resource "equinix_metal_port" "eth0" {
  bonded   = false
  port_id  = [for port in equinix_metal_device.esxi.ports : port.id if port.name == "eth0"][0]
  vlan_ids = var.vlan_id_loc3_res_eth_even
  depends_on = [
    equinix_metal_device.esxi,
    time_sleep.reboot_after_provisioning
  ]
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "equinix_metal_port" "eth1" {
  bonded   = false
  port_id  = [for port in equinix_metal_device.esxi.ports : port.id if port.name == "eth1"][0]
  vlan_ids = var.vlan_id_loc3_res_eth_odd
  depends_on = [
    equinix_metal_device.esxi,
    time_sleep.reboot_after_provisioning
  ]
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "equinix_metal_port" "eth2" {
  bonded   = false
  port_id  = [for port in equinix_metal_device.esxi.ports : port.id if port.name == "eth2"][0]
  vlan_ids = var.vlan_id_loc3_res_eth_even
  depends_on = [
    equinix_metal_device.esxi,
    time_sleep.reboot_after_provisioning
  ]
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "equinix_metal_port" "eth3" {
  bonded   = false
  port_id  = [for port in equinix_metal_device.esxi.ports : port.id if port.name == "eth3"][0]
  vlan_ids = var.vlan_id_loc3_res_eth_odd
  depends_on = [
    equinix_metal_device.esxi,
    time_sleep.reboot_after_provisioning
  ]
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

# Create sleep timer after vlans are added to ensure server is stable and ready to add to vCenter
resource "time_sleep" "pause_after_vlan" {
  create_duration = "2m"
  depends_on = [
    equinix_metal_port.eth0,
    equinix_metal_port.eth1,
    equinix_metal_port.eth2,
    equinix_metal_port.eth3
  ]
}
