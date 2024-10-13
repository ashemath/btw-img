#!/bin/sh

. ./defaults.ini

if [ -z $NAME ] ; then
    NAME="test";
fi
DIR="./$NAME";
MDPATH=$DIR/meta-data;
UDPATH=$DIR/user-data;

if [ -z $SIZE ]; then
    SIZE=25
fi

if [ ! -d $DIR ]; then
    echo "making folder for $NAME";
    mkdir $DIR;
else
    echo "$NAME Folder already exists"
fi

if [ ! -d ./creds/ ]; then
    echo "Making creds folder..."
    mkdir ./creds;
else
    echo "creds folder already exists. Moving on..."
fi

# Copy over the converted vanilla Debian .qcow2 disk
cp ./images/latest/disk.qcow2 $DIR/$NAME.qcow2
qemu-img resize $DIR/$NAME.qcow2 +${SIZE}G

# Inject more config value
if [ -z $USER ]; then
    USER="btw";
fi
echo "user set to: $USER"

if [ -z $SSHPUBFILE ]; then
    SSHPUBFILE=./creds/$NAME.pub;
fi
echo "SSHPUBFILE: $SSHPUBFILE"

if [ ! -f $SSHPUBFILE ]; then
    echo "SSH Key not found. Creating one non-interactively.."
    ssh-keygen -C $USER@$NAME -f ./creds/$NAME
fi

"Injecting $SSHPUBFILE"
SSHPUBKEY=$(cat $SSHPUBFILE);

# Let's start with the meta-data file
echo "instance-id: $NAME" > $MDPATH;
echo "local-hostname: $NAME" >> $MDPATH;

echo "#cloud-config" > $UDPATH;
echo "" >> $UDPATH;
echo "users:" >> $UDPATH;
echo "  - name: $USER" >> $UDPATH;
echo "    hashed_passwd: $(cat ./creds/pass.hash)" >> $UDPATH;
echo "    ssh_authorized_keys:" >> $UDPATH;
echo "      - $SSHPUBKEY" >> $UDPATH;
echo "    sudo: [\"ALL=(ALL) NOPASSWD:ALL\"]" >> $UDPATH;
echo "    groups: sudo" >> $UDPATH;
echo "    shell: /bin/bash" >> $UDPATH;

cd $DIR
echo "Generating cloud-init .iso for customizing at boot..."
genisoimage -output cidata.iso -V cidata -r -J user-data meta-data
echo "Launching VM"
echo $PWD
virt-install --check all=off --name=$NAME --ram=2048 --boot uefi --vcpus=2 --import --disk path=$NAME.qcow2,format=qcow2 --disk path=cidata.iso,device=cdrom --os-variant name=debian12 --network bridge=virbr0,model=virtio --graphics vnc,listen=0.0.0.0 --noautoconsole

