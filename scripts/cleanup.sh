#!/bin/sh
if [ $1 = '-c' ] && [ -f $2 ] ; then
    echo "loading config from $2";
    . $2;
fi

virsh shutdown $NAME
virsh destroy --domain $NAME
virsh undefine --nvram --domain $NAME

IP=$(cat creds/$NAME.ssh | cut -d "@" -f2);

ssh-keygen -f "/home/bill/.ssh/known_hosts" -R "$IP"

if [ -n $VMPATH ]; then
    rm -rf $VMPATH$NAME
elif [ -f ./creds/$NAME ] ; then
    rm -f ./creds/$NAME*;
fi
