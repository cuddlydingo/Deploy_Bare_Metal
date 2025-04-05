variable "esxi_name_set" {
  type = set(string)
  default = [
    "jpl-poc-phase81-007",
    "jpl-poc-phase81-008",
    "jpl-poc-phase81-009"
  ]
}

variable "auth_token" {
  default = ""
  type    = string
}

variable "vcenter_user_eqxloc3" {
  default = ""
  type    = string
}

variable "vcenter_pw_eqxloc3" {
  default = ""
  type    = string
}

variable "INFOBLOX_PASSWORD" {
  default     = ""
  description = "Stored in project CI/CD secrets"
  type        = string
}

variable "INFOBLOX_USERNAME" {
  default     = ""
  description = "Stored in project CI/CD secrets"
  type        = string
}

variable "billing_cycle" {
  default = ""
  type    = string
}

variable "esxi_domain" {
  default = ""
  type    = string
}

variable "metro" {
  default = ""
  type    = string
}

variable "esxi_version" {
  default = ""
  type    = string
}

variable "esxi_size" {
  default = ""
  type    = string
}

variable "project_id" {
  default = ""
  type    = string
}

variable "esxi_pw" {
  default = ""
  type    = string
}

variable "esxi_dns" {
  default = ""
  type    = string
}

variable "esxi_searchdomain" {
  default = ""
  type    = string
}

variable "esxi_ntp" {
  default = ""
  type    = string
}

variable "esxi_mgmtvlan" {
  default = ""
  type    = string
}

variable "esxi_mgmt_subnet" {
  default = ""
  type    = string
}

variable "esxi_storage_subnet" {
  default = ""
  type    = string
}
variable "esxi_vmotion_subnet" {
  default = ""
  type    = string
}

variable "esxi_gateway" {
  default = ""
  type    = string
}

variable "vlan_id_loc3_res_eth_odd" {
  type = list(any)
}

variable "vlan_id_loc3_res_eth_even" {
  type = list(any)
}

variable "vcenter_ip" {
  default = ""
  type    = string
}

variable "cluster_name" {
  default = ""
  type    = string
}

variable "esxi_plain_pw" {
  default = "pw_value"
  type    = string
}

variable "vds_mgmt" {
  type    = string
  default = "vds_name"
}

variable "vds_mgmt_portgroup" {
  type    = string
  default = "portgroup_name"
}

variable "vds_storage_1" {
  type    = string
  default = "vds_name"
}

variable "vds_storage_1_portgroup" {
  type    = string
  default = "portgroup_name"
}

variable "vds_storage_2" {
  type    = string
  default = "vds_name"
}

variable "vds_storage_2_portgroup" {
  type    = string
  default = "portgroup_name"
}

variable "vds_vmotion" {
  type    = string
  default = "vds_name"
}

variable "vds_vmotion_portgroup" {
  type    = string
  default = "portgroup_name"
}

variable "loc3_iscsi_dynamicdiscovery_ip_1" {
  type    = string
  default = "ipv4_value"
}

variable "loc3_iscsi_dynamicdiscovery_ip_2" {
  type    = string
  default = "ipv4_value"
}

variable "loc3_iscsi_dynamicdiscovery_port" {
  type    = string
  default = "port_value"
}

variable "esxi_v8_licensekey" {
  type    = string
  default = "licensekey_value"
}

variable "esxi_v8_baseline_iso" {
  type    = string
  default = "ESXi v8.0 U2b ISO"
}

variable "esxi_v8_baseline_patches" {
  type    = string
  default = "ESXi v8.0 U2b Patches"
}
