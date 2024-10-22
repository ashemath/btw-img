# btw-img
The all-in-one VM lab project.
- Stand up a development environment.
- Launch a VM to host Docker.
- Start a minimal Debian VM to explore System Administration.
- Build a custom virtual machine image. Codify the setup, so you can rebuild easily.
  Import the .qcow file into virtualbox, package up the .ova, and distribute to
  Windows users.

## What it's not
Private cloud infrastructure. While this project is a few steps away from managing
baremetal servers, there are other projects out there that do much of that very
well. What I do in this project is not designed to scale laterally.

The idea is to harness the power of KVM\QEMU without needing to know all about it
up front. Instead, I demonstrate launching Debian a few ways, and I codify every
step of the configuration process in a way that you, the reader, can take to
modify and use in your own work.

