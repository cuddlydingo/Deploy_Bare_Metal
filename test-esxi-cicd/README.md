## JPL Phase 8.1

## Phase Table

| TF Branch/Phase | Deploy Location | Features Added                                                                                                                                                                                                                                                             |
| --------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Phase 1         | RES             | Base deploy successful                                                                                                                                                                                                                                                     |
| Phase 2         | RES             | Kickstart sleep_time fixed                                                                                                                                                                                                                                                 |
| Phase 3         | RES             | CI/CD Pipeline and group/project restructure                                                                                                                                                                                                                               |
| Phase 4         | RES             | Relocated to https://example.com/test/equinix, vCenter integration successful                                                                                                                                                                                              |
| Phase 5         | RES             | Infoblox integration                                                                                                                                                                                                                                                       |
| Phase 6         | RES             | Integration and use of Powershell custom scripts for single ESXi host                                                                                                                                                                                                      |
| Phase 7.1       | RES             | Testing Multiple ESXi deployment using chained for_each resources                                                                                                                                                                                                          |
| Phase 7.1.2     | RES             | Technically successful for multiple dynamic ESXi, but encounters error with concurrent commands being called during VDS configuration on ESXi after being added to vCenter (during powershell execution) due primarily to terraform resources being created simultaneously |
| Phase 7.2       | RES             | Pivoting from "for_each" module in Phase 7.1.2, to have Powershell command use a dynamically-generated .csv file instead during initial add esxi to vCenter and initial vmkernal/VDS network advanced configuration                                                        |
| Phase 7.3       | RES             | Successful Phase                                                                                                                                                                                                                                                           |
| Phase 7.3.1     | RES             | Troubleshooting resource lock issues, and/or VMware Command latency issues.                                                                                                                                                                                                |
| Phase 7.4       | RES             | Switch to Terraform executing self-contained .ps1 powershell scripts, rather than executing powershell commands/cmdlets directly from Terraform 'local_exec' command blocks.                                                                                               |
| Phase 7.5       | RES             | Adding automation to automatically add each ESXi's iSCSi IQN to the NetApp Datastore(s).                                                                                                                                                                                   |
| Phase 8.0       | RES             | Initial commit                                                                                                                                                                                                                                                             |
| Phase 8.1       | RES             | Integrating CI/CD Pipelines                                                                                                                                                                                                                                                |

## NOTES

In the PowerShell Customization of the ESXi host, vSphere HA may need to be disabled before the host can be remediated against the baseline, especially if the ESXi is the only/first host in the cluster.
In the PowerShell Customization of the ESXi host, the local_exec execution will not accept Baseline Groups, only baselines.

In the adv_esxi_settings.ps1 file, before we start configuring virtual networking settings on the ESXi, we check to see if the ESXi server is being provisioned on one of two different hardware types:

1. SuperMicro hardware
2. Open19 hardware

The subtle difference between the hardwares lies, as far as we need be concerned, in the physical network adapter configurations. Namely, the "vmnic" numbers differ, depending on which hardware is being used. This difference does not impact performance or functionality, but will be a critical distinction when configuring the Distributed Virtual Switches on the ESXi within vCenter, later.

| Server Hardware | Physical Adapters Available at Initial Provisioning                                                   | VMNICs Used by vCenter                                             |
| --------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| SuperMicro      | vmnic0 <br> vmnic1 <br> vmnic2 _(selected by default)_ <br> vmnic3 <br> vmnic4 <br> vmnic5 <br> vusb0 | vmnic2 _(selected by default)_ <br> vmnic3 <br> vmnic4 <br> vmnic5 |
| Open19          | vmnic0 _(selected by default)_ <br> vmnic1 <br> vmnic2 <br> vmnic3                                    | vmnic0 _(selected by default)_ <br> vmnic1 <br> vmnic2 <br> vmnic3 |
