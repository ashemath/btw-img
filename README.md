#btw-img
System deployment and configuration tools by Bill the Wizard

## Status: Still incubating
Working on the automated deployment of a libvirt/KVM virtual machine
The first goal is to run a command like `make_minimal` and have libirt
setup a fresh Debian server booting off a virtual disk 
on EFI firmware. I'd like to get DHCP network configuration, and run a
post-configuration script to complete system configuration.

Maybe I'll try to install the docker engine:
```
sh -c "$(curl https://billthewizard.net/_static/install_docker.sh)"

```
