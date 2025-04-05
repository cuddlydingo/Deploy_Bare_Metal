# EQX Auth Tokens
auth_token = "auth_token_value"

# TF Local Testing Variables
vcenter_user_eqxloc3 = "administrator@eqxloc3.local"
vcenter_pw_eqxloc3   = "pw_value"
vcenter_ip           = "vcenter_ipv4"
cluster_name         = "eqxloc3-01"

# TF Local Infoblox Variables
INFOBLOX_PASSWORD = "pw_value"
INFOBLOX_USERNAME = "user_name_value"

# EQX Metal Variables
billing_cycle     = "hourly"
esxi_domain       = "eqx-loc3.example.com"
esxi_searchdomain = "example.com"
metro             = "dc"
esxi_version      = "vmware_esxi_8_0_vcf" # Production Value
esxi_size         = "n3.xlarge.x86"       # Production Value
# esxi_version        = "vmware_esxi_7_0_vcf" # Testing Value
# esxi_size           = "n2.xlarge.x86"       # Testing Value
project_id          = "project_id_value"
esxi_pw             = "esxi_pw_value"
esxi_dns            = "dns_ip_address"
esxi_ntp            = "ntp_ipv4_value"
esxi_mgmtvlan       = "vlan_id"
esxi_mgmt_subnet    = "subnet_value"
esxi_storage_subnet = "subnet_value"
esxi_vmotion_subnet = "subnet_value"
esxi_gateway        = "gateway_ipv4"
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
