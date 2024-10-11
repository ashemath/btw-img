# btw-img
After learning a bit about different linux installers, I decided
to stop doing any of that. Instead, we'll endeavor to  unpack a suitable
cloud image, edit the virtual disk on the admin workstation or hypervisor,
and image the baremetal\virtual disk.

I don't want to worry about problem solving these issues any more, so
it's time to polish up a new shiny automation framework with ansible.

btw-img endeavors to deliver a sensible baseline for a complete system
based around Debian. Ideally, this project an be a higher-caliber wizardlab.

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

It's a tall order, but I feel up for the challenge, and I usually want to go nuts on something
like this in the Fall.

