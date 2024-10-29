#!/bin/sh
if [ $1 = '-c' ] && [ -f $2 ] ; then
    echo "loading config from $2";
    . $2;
else
    echo "Clean target not valid."
    exit 1;
fi

if [ -f ~/.config/libvirt/qemu/save/$NAME.save ] ; then
    rm -f ~/.config/libvirt/qemu/save/$NAME.save
    echo "Removed $NAME.save!"
fi

virsh shutdown $NAME 1> /dev/null;
virsh undefine --nvram --domain $NAME 1> /dev/null
virsh destroy --domain $NAME 1> /dev/null

IP=$(cat creds/$NAME.ssh 1> /dev/null | cut -d "@" -f2);

if [ ! -z $IP ] ; then
    ssh-keygen -f "/home/bill/.ssh/known_hosts" -R "$IP"
fi

if [ -n $VMPATH ]; then
    rm -rf $VMPATH$NAME
elif [ -f ./creds/$NAME ] ; then
    rm -f ./creds/$NAME*;
fi
