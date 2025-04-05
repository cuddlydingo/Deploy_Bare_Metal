## JPL Phase 6

## Phase Table

| TF Branch/Phase | Deploy Location | Features Added                                                                    |
| --------------- | --------------- | --------------------------------------------------------------------------------- |
| Phase 1         | RES             | Base deploy successful                                                            |
| Phase 2         | RES             | Kickstart sleep_time fixed                                                        |
| Phase 3         | RES             | CI/CD Pipeline and group/project restructure                                      |
| Phase 4         | RES             | Relocated to https://example.com/test/equinix, vCenter integration successful |
| Phase 5         | RES             | Infoblox integration                                                              |
| Phase 6         | RES             | Integration and use of Powershell custom scripts for single ESXi host             |

## NOTES

In the PowerShell Customization of the ESXi host, vSphere HA may need to be disabled before the host can be remediated against the baseline, especially if the ESXi is the only/first host in the cluster.
In the PowerShell Customization of the ESXi host, the local_exec execution will not accept Baseline Groups, only baselines.

In the kickstart portion of custom_data parameter, we check to see if the ESXi server is being provisioned on one of two different hardware types:

1. SuperMicro hardware
2. Open19 hardware

The subtle difference between the hardwares lies, as far as we need be concerned, in the physical network adapter configurations. Namely, the "vmnic" numbers differ, depending on which hardware is being used. This difference does not impact performance or functionality, but will be a critical distinction when configuring the Distributed Virtual Switches on the ESXi within vCenter, later.

| Server Hardware | Physical Adapters Available at Initial Provisioning                                                   | VMNICs Used by vCenter                                             |
| --------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| SuperMicro      | vmnic0 <br> vmnic1 <br> vmnic2 _(selected by default)_ <br> vmnic3 <br> vmnic4 <br> vmnic5 <br> vusb0 | vmnic2 _(selected by default)_ <br> vmnic3 <br> vmnic4 <br> vmnic5 |
| Open19          | vmnic0 _(selected by default)_ <br> vmnic1 <br> vmnic2 <br> vmnic3                                    | vmnic0 _(selected by default)_ <br> vmnic1 <br> vmnic2 <br> vmnic3 |
