#!/bin/bash

# Define the number of VMs
num_vms=3

# Define an array of VM IPs
vm_ips=("VM0_IP" "VM1_IP" "VM2_IP")

# Loop through the VMs
for ((i=0; i<num_vms; i++))
do
    # Get the source and target VM IPs
    source_ip="${vm_ips[$i]}"
    target_ip="${vm_ips[($i+1)%num_vms]}"

    # Perform the ping operation
    ping -c 1 $target_ip >/dev/null 2>&1

    # Check the result and record it
    if [ $? -eq 0 ]; then
        echo "Ping from $source_ip to $target_ip: PASS"
    else
        echo "Ping from $source_ip to $target_ip: FAIL"
    fi
done
