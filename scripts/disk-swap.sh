#!/bin/sh

# Swap between the "builder" cloud image disk with the "spare" disk attached
# and a configuration with only the "spare" disk.

BUILDERSTATUS=$(virsh dominfo --domain builder | grep 'State' | awk '{ print $2 }');

if [ -f "./conf.d/$1.build" ] ; then
    . ./conf.d/$1.build;
    BUILDPATH="/tmp/$BUILDNAME/$BUILDNAME.qcow2"
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


if [ $VDA = "/tmp/builder/builder.qcow2" ] && [ $VDB = $BUILDPATH ]; then
    echo "Attaching the spare disk!";
    virsh detach-disk --domain builder /tmp/builder/builder.qcow2 --config
    virsh detach-disk --domain builder $BUILDPATH --config
    virsh attach-disk --domain builder $BUILDPATH --target vda --config
#elif [ $VDA = "$BUILDPATH" ] && [ $VDB="-" ] ; then
else
    echo "Attaching just the builder disk!";
    virsh detach-disk --domain builder $BUILDPATH --target vda --config
    virsh attach-disk --domain builder /tmp/builder/builder.qcow2 --target vda --config
    virsh attach-disk --domain builder $BUILDPATH --target vdb --config
fi

BUILDERSTATUS=$(virsh dominfo --domain builder | grep 'State' | awk '{ print $2 }');
if [ $BUILDERSTATUS = 'shut' ]; then
    virsh start --domain builder;
    echo "Staartup time!"
fi

