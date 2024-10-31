#!/bin/sh

# Swap between the "builder" cloud image disk with the "spare" disk attached
# and a configuration with only the "spare" disk.

BUILDERSTATUS=$(virsh dominfo --domain builder | grep 'State' | awk '{ print $2 }');

if [ -f "./conf.d/$1.build" ] ; then
    . ./conf.d/$1.build;
    BUILDPATH="/tmp/$BUILDNAME/$BUILDNAME.qcow2";
    DOBUILD=1;
else
    echo "Need build requires a valid config!"
    exit 1;
fi

if [ $BUILDERSTATUS = 'running' ]; then
    echo "Builder is on, turning it off!";
    virsh shutdown --domain builder;
    sleep 5;
elif [ $BUILDERSTATUS = 'shut' ]; then
    echo "Builder is already off!";
fi

VDA=` virsh domblklist --domain builder | grep 'vda' | awk '{ print $2 }' `;
VDB=` virsh domblklist --domain builder | grep 'vdb' | awk '{ print $2 }' `;
echo "VDA is $VDA";
echo "VDB is $VDB";

BUILDXML=/tmp/$BUILDNAME/$BUILDNAME.xml;
if [ $VDA = "/tmp/builder/builder.qcow2" ] && [ $VDB = $BUILDPATH ]; then
    echo "creating $BUILDXML VM with virt-xml!";
    virsh dumpxml --domain builder > $BUILDXML;
    echo "$(cat $BUILDXML | virt-xml --remove-device --disk 1)" > $BUILDXML;
    echo "$(cat $BUILDXML | virt-xml --remove-device --disk 1)" > $BUILDXML;
    echo "$(cat $BUILDXML | virt-xml --add-device --disk $BUILDPATH)" > $BUILDXML;
fi

BUILDERSTATUS=$(virsh dominfo --domain builder | grep 'State' | awk '{ print $2 }');
if [ $BUILDERSTATUS = 'shut' ] && [ $DOBUILD -eq 1 ]; then
    echo "Staartup time!"
    virsh create $BUILDXML;
fi

