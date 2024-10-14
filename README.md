# btw-img
System deployment and configuration tools by Bill the Wizard

## Philosophy
The goal is to have all the VMs and archives live in /tmp/.
Trying to play nice with networked /home/ directories, and 
to force good automation practice.

## How to try it out

### Setup Notes
Draft of the Required packages:
```

```
To use this project as a normal user without special libvirt group
membership, you need the `qemu-bridge-helper`.

To install qemu-bridge-helper:
```
sudo apt install qemu-system-common
sudo dnf install qemu-system-common
```

In order for the qemu-bridge-helper to work, it needs to have `setuid`
configured. Also, we need a file `/etc/qemu/bridge.conf` On Redhat, this might already be in place:
```
sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper
ls -la /usr/lib/qemu/qemu-bridge-helper
sudo echo "allow virbr0" > /etc/qemu/bridge.conf
```


### Makefile
I'll utilize a Makefile to feature the capabilities of this project.
At the moment, we launch the VM specified in default.ini, and we
SSH a couple instructions to update apt and install docker.

To launch a fresh Debian12 Virtual Machine and install Docker engine:
```
$ make default
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

The script runs `host -a $NAME 192.168.122.1`, so it's asking the default VM network virbr0 to resolve the VM by name. Next,
we parse the IP address. The suggested SSH command is printed last. I exploit this in the makefile to create an executable for
piping commands to the VM.

### scripts/cleanup.sh: 
Cleanup the files and configuration associated with a .ini file
Example usage:
`./script/cleanup -c default.ini`

## What next?
I need to automate deploying an ansible controller and PXE server.
Might just launch a VM with ./scripts/launch-virtual-machine.sh
and write a script to configure an ansible inventory and execute an
ansible playbook.
