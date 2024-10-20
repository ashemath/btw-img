#!/bin/sh

START=$PWD;

# Import default values. Substitute values provided by config.ini if supplied
. conf.d/default.conf;
if [ $1 = '-c' ] ; then
    CONFIG=$2
    echo "loading config from $CONFIG";
    . $CONFIG;
fi

START=$PWD;
ARCHIVEPATH="/tmp/"
DIR="${VMPATH}/${NAME}";
MDPATH=${DIR}/meta-data;
UDPATH=${DIR}/user-data;

if [ ! -d $DIR ]; then
    echo "making folder for $NAME";
    mkdir $DIR;
else
    echo "$NAME Folder already exists"
fi

if [ ! -d ./creds ]; then
    echo "Making creds folder..."
    mkdir ./creds;
else
    echo "creds folder already exists. Moving on..."
fi

# Copy over the converted vanilla Debian .qcow2 disk
cp ${ARCHIVEPATH}/images/latest/disk.qcow2 ${DIR}/${NAME}.qcow2
qemu-img resize ${DIR}/${NAME}.qcow2 +${SIZE}G

if [ ! -z $BUILDPATH ] ; then
    cd /tmp;
    qemu-img create -f qcow2 $BUILDNAME $BUILDSIZE;
    cd $START;
else
    echo "Did not create spare disk. Buildpath is $BUILDPATH";
fi

if [ -z $SSHPUBFILE ]; then
    SSHPUBFILE=./creds/$NAME.pub;
fi

if [ ! -f $SSHPUBFILE ]; then
    echo "SSH Key not found. Creating one non-interactively.."
    ssh-keygen -N '' -C $USER@$NAME -f ./creds/$NAME
fi

echo "Injecting ""$SSHPUBFILE"" "
SSHPUBKEY=$(cat $SSHPUBFILE);

# Let's start with the meta-data file
cat << EOF > $MDPATH
instance-id: $NAME
local-hostname: $NAME
EOF

cat << EOF > $UDPATH
#cloud-config
users:
- name: $USER
  ssh_authorized_keys:
    - $SSHPUBKEY
  sudo: ALL=(ALL) NOPASSWD:ALL
  groups: sudo
  shell: /bin/bash
EOF

if [ ! -z $BUILDPATH ] ; then
    echo "Adding the spare disk! buildpath is: $BUILDPATH"
    disks="--disk path=$NAME.qcow2,format=qcow2 --disk path=$BUILDPATH,format=qcow2";
else
    echo "No BUILDPATH";
    disks="--disk path=$NAME.qcow2,format=qcow2";
fi

cd $DIR
echo "Generating cloud-init .iso for customizing at boot..."
genisoimage -output cidata.iso -V cidata -r -J user-data meta-data
echo "Launching VM"
echo $PWD
virt-install --check all=off --name=$NAME --ram=$RAM --boot uefi --vcpus=$VCPUS \
    --import $disks --disk path=cidata.iso,device=cdrom --os-variant name=debian11 \
    --network bridge=virbr0,model=virtio \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole

cd $START
echo "Starting deployment verification!..."
env SSHKEYFILE=$SSHKEYFILE ./scripts/verify-deployment.sh -c $CONFIG
