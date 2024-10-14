#!/bin/sh

ARCHIVEPATH="/tmp/"
START=$PWD;

if [ -z $1 ] ; then
    echo "loading default.ini"
    . ./default.ini;
else
    if [ $1 = '-c' ] ; then
        echo "loading config from $2";
        . ./$2;
    fi
fi

DIR="${VMPATH}/${NAME}";
echo "VMPATH is ${VMPATH}. DIR is ${DIR} ARCHIVEPATH is ${ARCHIVEPATH}"
MDPATH=${DIR}/meta-data;
UDPATH=${DIR}/user-data;

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
cp ${ARCHIVEPATH}/images/latest/disk.qcow2 ${DIR}/${NAME}.qcow2
qemu-img resize ${DIR}/${NAME}.qcow2 +${SIZE}G

if [ -z $SSHPUBFILE ]; then
    SSHPUBFILE=./creds/$NAME.pub;
fi

if [ ! -f $SSHPUBFILE ]; then
    echo "SSH Key not found. Creating one non-interactively.."
    ssh-keygen -C $USER@$NAME -f ./creds/$NAME
fi

echo "Injecting ""$SSHPUBFILE"" "
SSHPUBKEY=$(cat $SSHPUBFILE);

# Let's start with the meta-data file
echo "instance-id: $NAME" > $MDPATH;
echo "local-hostname: $NAME" >> $MDPATH;

echo "#cloud-config" > $UDPATH;
echo "" >> $UDPATH;
echo "users:" >> $UDPATH;
echo "  - name: $USER" >> $UDPATH;
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

cd $START
env NAME=$NAME USER=$USER SSHKEYFILE=$SSHKEYFILE ./scripts/verify-deployment.sh
