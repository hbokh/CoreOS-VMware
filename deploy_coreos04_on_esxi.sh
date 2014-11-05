#!/bin/sh
# Inspird by William Lam, www.virtuallyghetto.com
# Simple script to use CoreOS image with open-vm-tools & run on ESXi
# Adapted by hbokh, November 2014

# Path of Datastore to store CoreOS
DATASTORE_PATH=/vmfs/volumes/datastore1

# VM Network to connect CoreOS to
VM_NETWORK="VM Network"

# Name of VM
VM_NAME=CoreOS04

# No bunzip2 on ESXi... So pull this images manually on diff. host:
# wget http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vmware_image.vmdk.bz2
# and extract on OS X, Linux or Windows
# Then SCP coreos_production_vmware_image.vmdk to ${DATASTORE_PATH}/${VM_NAME}

# Creates CoreOS VM Directory by hand
#mkdir -p ${DATASTORE_PATH}/${VM_NAME}
cd ${DATASTORE_PATH}/${VM_NAME}

# Download CoreOS .vmx-file
wget http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vmware.vmx

# Convert VMDK from 2gbsparse from hosted products to Thin
vmkfstools -i coreos_production_vmware_image.vmdk -d thin coreos.vmdk

# Move the original VMDK to templates for later use
mv coreos_production_vmware_image.vmdk ../templates/

# Update CoreOS VMX to reference new VMDK
sed -i 's/coreos_production_vmware_image.vmdk/coreos.vmdk/g' coreos_production_vmware.vmx

# Update CoreOS VMX w/new VM Name
sed -i "s/displayName.*/displayName = \"${VM_NAME}\"/g" coreos_production_vmware.vmx

# Update CoreOS VMX to map to VM Network
echo "ethernet0.networkName = \"${VM_NETWORK}\"" >> coreos_production_vmware.vmx

#### Static IP address ####
sed -i "s/generated/static/g" coreos_production_vmware.vmx
# MAC-addresses starting with "00:50:56" are VMware-specific
# Add this in your DHCP-server too, to make live easier
echo "ethernet0.address = 00:50:56:00:00:04 " >> coreos_production_vmware.vmx

# Register CoreOS VM which returns VM ID
VM_ID=$(vim-cmd solo/register ${DATASTORE_PATH}/${VM_NAME}/coreos_production_vmware.vmx)

# Upgrade CoreOS Virtual Hardware from 4 to 9
vim-cmd vmsvc/upgrade ${VM_ID} vmx-09

# PowerOn CoreOS VM
vim-cmd vmsvc/power.on ${VM_ID}

# Reset CoreOS VM to quickly get DHCP address
vim-cmd vmsvc/power.reset ${VM_ID}
