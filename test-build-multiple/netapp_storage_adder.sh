#! /bin/bash

svc_pw='pw_value'

# Remove double-quote marks from Powershell-generated CSV
tr -d '"' <esxi_netapp_iqn.csv >esxi_netapp_iqn_final.csv

skip_headers=1
while IFS=, read -r Hostname IQN; do
    if ((skip_headers)); then
        ((skip_headers--))
    else
        IQN=$(echo $IQN | sed 's/\r//g')
        # The '-n' ssh option (below) is necessary to have ssh read from /dev/null, rather than stdin, so that the while loop processes for each line of the .csv input
        sshpass -p$svc_pw ssh -n "svc_user"@storage_ipv4 "lun igroup add -vserver stor_loc3_san01 -igroup eqxloc3-01 -initiator $IQN"
        sleep 10
    fi
done <esxi_netapp_iqn_final.csv
