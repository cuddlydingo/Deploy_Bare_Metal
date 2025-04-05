variable "auth_token" {
  type = string
}
variable "project_id" {
  type = string
}
variable "metro" {
  type = string
}
variable "billing_cycle" {
  type = string
}
variable "esxi_version" {
  type = string
}
variable "esxi_pw" {
  type = string
}
variable "esxi_size" {
  type = string
}
variable "esxi_gateway" {
  type = string
}
variable "esxi_mgmt_subnet" {
  type = string
}
variable "esxi_storage_subnet" {
  type = string
}
variable "esxi_vmotion_subnet" {
  type = string
}
variable "esxi_dns" {
  type = string
}
variable "esxi_domain" {
  type = string
}
variable "esxi_searchdomain" {
  type = string
}
variable "esxi_mgmtvlan" {
  type = string
}
variable "esxi_storagevlan" {
  type = string
}
variable "esxi_vmotionvlan" {
  type = string
}
variable "esxi_ntp" {
  type = string
}
variable "esxi_name" {
  type = string
}
variable "esxi_mgmt_ip" {
  type    = string
  default = ""
}
variable "esxi_vmotion_ip" {
  type    = string
  default = ""
}
variable "esxi_storage_1_ip" {
  type    = string
  default = ""
}
variable "esxi_storage_2_ip" {
  type    = string
  default = ""
}
variable "vlan_id_loc3_res_eth_odd" {
  type = list(any)
}
variable "vlan_id_loc3_res_eth_even" {
  type = list(any)
}
variable "vcenter_user_eqxloc3" {
  type        = string
  description = "Stored in CI/CD Variables"
}
variable "vcenter_pw_eqxloc3" {
  type        = string
  description = "Stored in CI/CD Variables"
}
# variable "AWS_ACCESS_KEY_ID" {
#   type = string
#   description = "Stored in CI/CD Variables"
# }
# variable "AWS_SECRET_ACCESS_KEY" {
#   type = string
#   description = "Stored in CI/CD Variables"
# }
# variable "s3_bucket"{
#   description = "Grabbed from gitlab-ci.yaml"
#   default = ""
# }
variable "ci_pipeline_id" {
  description = "Gitlab CI variable for pipeline"
  default     = ""
}
variable "ci_commit_ref_name" {
  description = "Gitlab CI Variable Commit Ref Name"
  default     = ""
}
variable "ci_project_dir" {
  description = "Gitlab CI Variable for project dir"
  default     = ""
}
variable "src_token" {
  description = "In gitlab.yml file"
  default     = ""
}
variable "gitlab_project_path" {
  description = "Gitlab Project Path from STATE_PATH var"
  default     = ""
}
variable "INFOBLOX_PASSWORD" {
  type    = string
  default = ""
}
variable "INFOBLOX_USERNAME" {
  type    = string
  default = ""
}
variable "TF_VAR_vcenter_pw_eqxloc3" {
  type    = string
  default = ""
}
variable "TF_VAR_vcenter_user_eqxloc3" {
  type    = string
  default = ""
}
variable "TF_VAR_tpl_password" {
  type    = string
  default = ""
}
# variable "esxi_hostname" {
#   type    = string
#   default = ""
# }
variable "vcenter_ip" {
  type    = string
  default = "vcenter_ipv4"
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
variable "vds_mgmt" {
  type    = string
  default = "vds_name"
}
variable "vds_mgmt_portgroup" {
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
variable "cluster_name" {
  type    = string
  default = "cluster_name_value"
}
variable "esxi_plain_pw" {
  type    = string
  default = "pw_value"
}
variable "esxi_baseline_name" {
  type    = string
  default = "esxi_v8_u2b_mastersword"
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
