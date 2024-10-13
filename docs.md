# btw-img
After learning a bit about different linux installers, I decided
to stop doing any of that. Instead, we'll endeavor to  unpack a suitable
cloud image, edit the virtual disk on the admin workstation or hypervisor,
and image the baremetal\virtual disk.

I don't want to worry about problem solving these issues any more, so
it's time to polish up a new shiny automation framework with ansible.

btw-img endeavors to deliver a sensible baseline for a complete system
based around Debian. Ideally, this project an be a higher-caliber wizardlab.

finding this helpful:
[https://sumit-ghosh.com/posts/create-vm-using-libvirt-cloud-images-cloud-init/]\
(https://sumit-ghosh.com/posts/create-vm-using-libvirt-cloud-images-cloud-init/)
## Finding a focus
Wizardlab was a lot of fun to design, but it's too loose about how it operates.
While I could go ahead and rework all of that code, I feel like taking some
more new approaches, and I would struggle to simplify.

btw-img will also meet different needs: development environment, image automation
laboratory, infrastructure configuration testbed, etc. To start, I will develop
a Proof-of-Concept Debian install with ansible. Later, I will bolt on the minimal
amount of wizardlab code that I need to enable this to be a standalone project.

## The motivation
There's lots of ways to setup an Operating System. The options are frankly, quite
confusing.

I started out in 2008 by burning an `.iso` file to a CD-RW and booting
from the disk drive. In 2024, you can still install Linux this way, but I burn
an image to a USB storage device.

Next, we have PXE booting over the network. Using PXE, we can start up a computer
without an Operating System isntalled to disk. Once you are setup to interface with
the disk in a lightweight Linux environment, we can write a reference image to our disk
with `partclone`.

Getting a reference image to send to the physical disk is a chore. Do it really carefully
by hand once in a VM, reboot into the PXE environment, and capture the disk partitions
as raw image files. You can speed up configuration using tools like Ansible, but developers
usually try not to reinvent the wheel.

Enter tools like Hashicorp's Packer. Packer builds a reference cloud image and can output
a template that's compatible with your hypervisor for popping out VM's on demand. One
slight problem: getting a baremetal machine to boot on EFI firmware from a tiny cloud
image.

It's a strange problem. Basically, the default firmware type rules the game of how the thing
is configured to boot. Booting EFI will require some extra work, and careful configuration, but
we can stand on the shoulder of giants to get there.

##  The Vision for btw-img
Let's provision a virtual machine disk, Configure a mount into that virtual disk
on our hypervisor, setup a `chroot` environment to further customize the virtual disk,
customize the minimum software we need, and output the 
raw disk image files that we need to configure our bare-metal machines at scale.

It's a tall order, but I feel up for the challenge, and I usually want to go nuts on something like this in the Fall.

## Getting the pieces together
The first step was working out how to acquire the cloud image that I need. One
option is to build my own. I can do that by studying cloud images and learning to replicate
their process, by using a tool that can create them for me, like Packer, or I can
adapt a readily available cloud image, direct from Debian.

I like the third approach. It gets me to the goal the fastest, I can rely on the 
process being viable long term. With Packer, I would be relying on templates published by
others to get started, and their suitability for my needs would be limited.

Instead, I'll begin with a very generic image, and install what I need afterwards. It's
a nice middle ground between deploying  a static disk image and installing everything
fresh onto partitions.

The script I developed to prepare the image will transfer the latest generic 
cloud image in archive format  from Debian, check the sha512 integrity sum, extract the raw disk file, and convert it to a .qcow2 file format.

## Meta-data and User-data
Cloud-init is an automation framework that enables customization of the cloud image
on that first boot. It's a slick tool. The cloud-init configuration data can be 
transfered to the host in a couple different ways.

We can make a special tiny `.iso` format physical partition on our disk that hosts
the meta-data and user-data. After installation, this partition should probably be
destroyed. The nice aspect of this approach is that the device has everything it needs
on disk to get setup. A problem with a network driver will not keep a machine like this 
from making it through a reboot.

Some distributions like Debian will respond to data being dropped into certain system
directories. I hope to explore this as a way to avoid the `.iso` partition and network
delivery.

In baremetal and virtual environment, we can use a webserver to host the meta-data and
user-data. By setting up on an isolated network segment, we can restrict the access to these
configuration files, and we can load those files into RAM only, instead.

In virtualized applications, the network method appears to be the most sensible approach.
On baremetal, having the configuration written to the disk makes the system much more
reliable, and reliability is necessary when you are swinging for scale.

Networking can be challenging to diagnose, troubleshoot, and repair. Sometimes you 
can't just upgrade a ton of gear. I hope to find a way to inject cloud-in configuration
into a baremetal bootable image, so baremetal servers can be installed with the same
project as I used with VMs

For image creation in the VM, we can use geniso to store the userdata and metadata on a tiny .iso that is mounted on VM creation. If we want to export those partitions for baremetal
installation, it's just a matter ofbooting it, letting cloud-init do it's thing, and capturing the partiution data with `partclone` before putting it down to disk.

Easier said than done.

## How to configure cloud-init
A goal of this project is to utilized the best tools for each subtask in the projects
automation workflow. For example, the `prepare-cloud-img.sh` script is POSIX shell.

I went with the shell script because I didn't need do much in terms of variable manipulation.
I could do more with variables easier with `bash` scripting, but bash is a little
different on each distribution, so portability is a small issue with `bash` scripting.
I take the same approach with `launch-virtual-disk.sh`. After running, you'll have a Debian
virtual machine setup according to values set in `defaults.ini`

Let's say you are using the default settings in this project's `defaults.ini`. The
`launch-virtual-machine.sh` script asks you to enter a password when it generates your
ssh key.

Run `sudo virsh net-dhcp-leases --network default` to find the IP of your VM.
From the project directory, you can ssh the VM you just stood up with:
`ssh btw@192.168.122.X`


## Delivery System
If all you want to do is produce a single VM for development, the project produces
a reference Virtual Machine that will probably suit your needs. If you want to
produce a whole mess of Virtual Machines in production, Terraform from Hasicorp
does a very good job and is compatible with Cloud providers.

I'll probably need to add a Terraform configuration later on, but for now my
focus is on deploying to baremetal or Virtual machines using a PXE boot server.
Vagrant does a good job at putting up a single server, and I do not need a custom
Debian server to install `dnsmasq` and provide PXE services onto a virtual interface.

Configure a linux bridge between the virtual interface and your physical interface,
drop that into a configured VLAN on your infrastructure, and now you can install Debian
anywhere, on demand.

A well configured system shouldn't have it's ip address baked into it's configuration
anyways, and we can update production DNS and DHCP using a parallel process, and
production systems can manage those services after system deployment.

`dnsmasq` management from the Vagrant launched VM is viable too, depending on your usecase.
Networking between hypervisors would require some creativity, and this project isn't
about setting up production DNS/DHCP. Rather, it's a system for getting Debian onto
a computer, anywhere, and at any scale.

I'll sidestep around dictating how people do DHCP/DNS because everyone's shop has an opinion
about managing tons of ip addresses.

## Ansbile-driven custom Operating System pipeline
I hope to design CI/CD integration that will be suitable for use in gitlab or alike.
The itegration could publish ready-made disk images for virtual or baremetal deployment.
Hoping to stay under the size limit for a free github repositiory for minimal Debian.

## The two stages of configuration
Cloud-int: Format disk partitions, setup a local admin account, install and enable core
functions like SSH or ZFS.

Ansible: Transform the minimal system installation into whatever tricked out server the
use-case requires. Install IDEs and System Admin tools, setup containerization, configure
hypervisor or file services, install a Code Versioning System.

## Extending the idea of Wizardlab

Wizardlab is a project that centers around a Vagrantfile and Ansible. Vagrant sets up
a base Debian server, and Ansible takes care of the rest. btw-img is a system for setting
up a customized Debian Operating system on baremetal or in a virtual machine. Rather than
spinning up a Vagrant-box from wherever, we will juice up a pure cloud minimal 
image from Debian. Taking this approach gets us close enough to the configuration options
we need to adapt configuration for disparate hardware.

btw-img is an opportunity to translate the ideas in wizardlab the to
baremetal and/or production environments.

## Ideas:
- Minimal Debian
- Proxmox
- Graphical Debian
- btwd: Bill the Wizard Desktop
  Sway desktop on Debian with sutomization by Bill the Wizard
- Proxmox with BTWD: Nice little GUI for an All-in-One Test/Develop server.

## Disk Partitioning and Advanced Storage capabilities
Installing an operating system in this manager makes advanced configuration options easier,
like root-on-ZFS, and mdadm. Managing the low-level configuration with Ansible makes
all sorts of customization possible.

