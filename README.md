#btw-img
System deployment and configuration tools by Bill the Wizard

## Status: Needs Makefile...
The project consists of a few scripts:
### scripts/prepare-cloud-img.sh: 
Download and prepare for install the latest Debian12 Generic Cloud image
`./scripts/prepare-cloud-img.sh`

### scripts/launch-virtual-machine.sh: 
Launch a Virtual machine based on the contents of a .ini file.  
`./scripts/launch-virtual-machine.sh -c default.ini`

### scripts/verify-deployment.sh:
Wait for Libvirtd networking to update the DHCP address of our virtual machine,
and display a helpful suggestion on how to connect to the shiny new virtual machine.

### scripts/cleanup.sh: 
Cleanup the files and configuration associated with a .ini file
`./script/cleanup -c default.ini`

## What next?
I need to automate deploying an ansible controller and PXE server.
Might just launch a VM with ./scripts/launch-virtual-machine.sh
and write a script to configure an ansible inventory and execute an
ansible playbook.
.
Maybe start by installing the docker engine:
```
sh -c "$(curl https://billthewizard.net/_static/install_docker.sh)"

```
