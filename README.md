# btw-img
System deployment and configuration tools by Bill the Wizard

## Status
I have worked out how to transition from the cloud image VM to the system wew build with
the chroot on the spare disk. Next, we'll go into another round of configuration management
to adjust properties that we can't set in the chroot environment, like `hostname`.

While we're at it, we'll have an opportunity to install additional software like a desktop environment, IDE, productivity suite, docker engine, etc.


## Design Goal:
Static framework of shell scripts to customize and launch Debian 
virtual machines without administrative privileges.

Build a custom Operating System image without using sudo
privileges. Launch a quick VM for testing your project.
Deploy a system image to hundreds of computers in minutes.

Add or subtract from the `conf.d/` to enable or disable features.

## How to try it out

### Setup Notes
Draft of the Required packages:
On Debian:
```
sudo apt install bind9-dnsutils qemu-system libvirt-daemon-system qemu-system-common
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
Here's how we get fixed up on Debian:
```
sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper
ls -la /usr/lib/qemu/qemu-bridge-helper
sudo echo "allow virbr0" > /etc/qemu/bridge.conf
```

### vmctl script
The vmctl script is an interface to scripts that manage the lifecycle of the VMs. 
For example:
```
### Launches the 2 VCPU 2048MB 10GB "default" System
./vmctl launch default

### Launches the 4 VCPU 4096MB 20GB "docker" System
./vmctl launch docker

### Does cleanup on all VMs under configs/
./vmctl clean all

### Copy the configs/default.conf to a new file called configs/testvm.conf
cp conf.d/default.conf conf.d/testvm.conf

### Change the name from default to testvm
sed -i "s/default/testvm/" conf.d/testvm.conf

### launch the new VM
./vmctl launch testvm

### Cleanup the new VM
./vmctl clean testvmm

### Build a custom debian bootable .qcow2 disk image, debootstrap style
./vmctl build debian

## Connect to a VM by executing the .ssh file under creds/
./creds/testvm.ssh
```


To launch a fresh Debian12 Virtual Machine and install Docker engine:
```
$ ./vmctl launch docker
```
Make creates a executable file to launch a ssh session. Execute that file,
and take Docker for a spin:
```
user@Local $./creds/default.ssh
btw@test $ docker run hello-world
```

To open up the machine in virt-manager, you may need to click on 
"File -> Add Connection", click the "Hypervisor:" dropdown, and select 
"QEMU/KVM User Session".

User Session VMs show up under a sepearate section than other "System" VMs
that were started with `libvirt` group permissions.

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
Launch a Virtual machine based on the contents of a .conf file.
Example usage:
`./scripts/launch-virtual-machine.sh -c conf.d/default.conf`

### scripts/verify-deployment.sh:
Example usage:
`./scripts/verify-deployment.sh -c conf.d/default.conf`
Wait for Libvirtd networking to update the DHCP address of our virtual machine,
and display a helpful suggestion on how to connect to the shiny new virtual machine.

The script runs `host -a $NAME 192.168.122.1`, so it's asking the default VM network virbr0 to resolve the VM by name. Next,
we parse the IP address. The suggested SSH command is printed last. I exploit this in the makefile to create an executable for
piping commands to the VM.

### scripts/cleanup.sh: 
Cleanup the files and configuration associated with a .ini file
Example usage:
`./script/cleanup -c conf.d/default.conf`

## What next?
I need to automate deploying an ansible controller and PXE server.
Might just launch a VM with ./scripts/launch-virtual-machine.sh
and write a script to configure an ansible inventory and execute an
ansible playbook.
