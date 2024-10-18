#!/bin/sh
. conf.d/default.conf
if [ $1 = '-c' ] ; then
    echo "loading config from $2";
    . $2;
fi

virsh shutdown $NAME
virsh destroy --domain $NAME
virsh undefine --nvram --domain $NAME
rm -rf $VMPATH/$NAME
rm -f ./creds/$NAME*
