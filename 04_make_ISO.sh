# Create a temp directory with the proper folder structure
mkdir -p /tmp/new-drive/openstack/latest

# Copy the user_data file to the proper location
cp user_data_04 /tmp/new-drive/openstack/latest/user_data

# Create the ISO
mkisofs -R -V config-2 -o configdrive.iso /tmp/new-drive

# Move the ISO to the ISOs NFS share
mv configdrive.iso coreos04-config.iso

# Remove the temporary folder structure
rm -rf /tmp/new-drive/
