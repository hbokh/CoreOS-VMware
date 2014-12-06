# CoreOS VMware images deployment


## Update, 20141107

William Lam from VMware picked this up pretty quick and created his own, far better script around fetching of the images. Check his blog-post:
[How to quickly deploy new CoreOS Image w/VMware Tools on ESXi?](http://www.virtuallyghetto.com/2014/11/how-to-quickly-deploy-new-coreos-image-wvmware-tools-on-esxi.html)

However, see this [Twitter-conversation](https://twitter.com/lamw/status/530392044229767168) where he left off (for now).  
In short: **you won't be able to login if you don't attach a custom ISO to the VM(s)!**

## What
  
Latest releases of CoreOS' VMware-images now include open-vm-tools.  
This is a small project to use these instead of the 'vmware\_insecure' images, and be prepared for the future.
Check out this [GitHub-comment](https://github.com/coreos/coreos-overlay/issues/499#issuecomment-58461747):  *This only applies to the vmware image, the older vmware\_insecure image will eventually be killed off.*  

**Killed off** ... time to get started!


## How

You need 2 files from CoreOS, e.g. at http://alpha.release.core-os.net/amd64-usr/current/

- coreos\_production\_vmware.vmx
- coreos\_production\_vmware\_image.vmdk.bz2

See `deploy_coreos04_on_esxi.sh` for some details:

- you need to bunzip2 the .vmdk on a different host than the ESXi-server
- create VM-folder by hand on ESXi: `mkdir -p ${DATASTORE_PATH}/${VM_NAME}`
- SCP (secure copy) the deflated .vmdk to the ESXi datastore
- a DHCP-reservation for a fixed IP-address is preferred

To enable a user (login-account), etcd and fleet add an ISO-image to the VM, as a config-drive with the label `config-2`.  
Edit file `user_data_04` for specific settings (change IP-address, GitHub-name) and file `04_make_ISO.sh` to create the ISO-image from these settings. My ISO-images are 96K in size.

**Hint**: if you need `mkisofs` on OS X, install 'dvdrtools' with Homebrew: `brew install dvdrtools`.  


## Deploy

You can deploy directly on ESXi in sub-directory `templates` on the datastore. You need to create this directory by hand.

```
/vmfs/volumes/datastore1/templates # ./deploy_coreos04_on_esxi.sh
Destination disk format: VMFS thin-provisioned
Cloning disk 'coreos_production_vmware_image.vmdk'...
Clone: 100% done.
Powering on VM:
Reset VM:
```

After this, power down the VM and add the ISO-image. Restart the VM.  
You can login with your Github-ID and its SSH-keys.


## Number ~~five~~ four is alive

I choose `coreos04` in the scripts, because I already had 3 CoreOS-hosts running as 'vmware_insecure' images. But number 4 seems to be playing along nicely with the rest: 

```
hbokh@coreos04 ~ $ fleetctl list-machines  
MACHINE		IP		    METADATA  
6ed4b296...	192.168.1.3	-  
85941ee5...	192.168.1.4	-  
85f337f8...	192.168.1.2	-  
90924c46...	192.168.1.1	-
```

**Note**: The `$private_ipv4` and `$public_ipv4` substitution variables referenced in other documents are not supported on VMware. See this [link](https://coreos.com/docs/running-coreos/platforms/vmware/).  

This is where VMware is lacking a metadata service (as opposed to Vagrant / Virtualbox and OpenStack).
So you will need a different and unique small ISO-image for EVERY separate CoreOS guest on VMware.


## Issues

- No bunzip2 on VMware ESXi. You'll have to deflate the .vmdk on a different system and SCP it over.

## Thanks

Originally inspired by & taken from [deploy_coreos_on_esxi.sh](https://github.com/lamw/vghetto-scripts/blob/master/shell/deploy_coreos_on_esxi.sh), by William Lam.
