auth_token = "auth_token_value"
project_id = "project_id_value"

# Metro for this stack
metro = "choose_a_metro"

## Provisioning Variables ##
billing_cycle = "hourly"
esxi_dns      = "dns_ip_address"
esxi_domain   = "example.com"
esxi_gateway  = "gateway_ipv4_address"
# esxi_hostname = join("", [var.esxi_name, ".", var.esxi_domain])
# esxi_mgmt_ip        = "ipv4_value" # removed with infoblox integration, now chosen automagically
esxi_mgmt_subnet  = "255.255.255.0"
esxi_mgmtvlan     = "vlan_value"
esxi_name         = "jpl-phase6-poc-15" # need to variable-ize for multiple ESXi
esxi_ntp          = "ntp_ipv4_value"
esxi_pw           = "esxi_pw_value"
esxi_searchdomain = "example.com"
esxi_size         = "n3.xlarge.x86"
# esxi_storage_1_ip   = "172.0.0.1" # jpl-phase6-poc-01.example.com | # removed with infoblox integration, now chosen automagically
# esxi_storage_2_ip   = "172.0.0.2" # jpl-phase6-poc-02.example.com | # removed with infoblox integration, now chosen automagically
esxi_storage_subnet = "subnet_value"
esxi_storagevlan    = "esxi_storagevlan_value"
esxi_version        = "vmware_esxi_8_0_vcf"
esxi_vmotion_ip     = "vmotion_ipv4_value" # need to figure out how to increment
esxi_vmotion_subnet = "subnet_value"
esxi_vmotionvlan    = "esxi_vmotionvlan_value"
vlan_id_loc3_res_eth_odd = [
  "vlan_uuid",
  "vlan_uuid",
  "vlan_uuid"
]
vlan_id_loc3_res_eth_even = [
  "vlan_uuid",
  "vlan_uuid",
  "vlan_uuid"
]

# TF Local Testing Variables
vcenter_user_eqxloc3 = "administrator@eqxloc3.local"
vcenter_pw_eqxloc3   = "pw_value"
vcenter_ip           = "vcenter_ipv4"

INFOBLOX_PASSWORD           = "pw_value"
INFOBLOX_USERNAME           = "user_name_value"
TF_VAR_vcenter_pw_eqxloc3   = "pw_value"
TF_VAR_vcenter_user_eqxloc3 = "username_value"
TF_VAR_tpl_password         = "pw_value"
