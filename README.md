# btw-img
System deployment and configuration tools by Bill the Wizard

## Philosophy
The goal is to have all the VMs and archives live in /tmp/.
Trying to play nice with networked /home/ directories, and 
to force good automation practice.

## How to try it out
### Makefile
I'll utilize a Makefile to feature the capabilities of this project.
At the moment, we launch the VM specified in default.ini, and we
SSH a couple instructions to update apt and install docker.

To launch a fresh Debian12 Virtual Machine and install Docker engine:
```
$ make default
```
Make creates a executable file to launch a ssh session. Execute that file,
and take Docker for a spin:
```
user@Local $./creds/default.ssh
btw@test $ docker run hello-world
```

To clean up after that demonstration:
```
$ make clean_default
```

If you want to put this project through it's paces, maybe to
see if you have libvirt working right:
```
$ make test
```
This is launching the default VM and destroying it after all that work.

### The Scripts
The project consists of a few scripts:
### scripts/prepare-cloud-img.sh: 
Download and prepare for install the latest Debian12 Generic Cloud image
`./scripts/prepare-cloud-img.sh`

### scripts/launch-virtual-machine.sh: 
Launch a Virtual machine based on the contents of a .ini file.  
Example usage:
`./scripts/launch-virtual-machine.sh -c default.ini`

### scripts/verify-deployment.sh:
Example usage:
`./scripts/verify-deployment.sh -c default.ini`
Wait for Libvirtd networking to update the DHCP address of our virtual machine,
and display a helpful suggestion on how to connect to the shiny new virtual machine.

It's a bit of a libvirt hack that repeatedly ping the VM name until it
can resolve. At that point, the script calls `host` and parses the IP address.
The suggested SSH command is printed last.

### scripts/cleanup.sh: 
Cleanup the files and configuration associated with a .ini file
Example usage:
`./script/cleanup -c default.ini`

## What next?
I need to automate deploying an ansible controller and PXE server.
Might just launch a VM with ./scripts/launch-virtual-machine.sh
and write a script to configure an ansible inventory and execute an
ansible playbook.
