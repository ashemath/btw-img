#!/bin/sh

## Wait for the IP address to update in libvirt's DHCP service
## display helpful suggestion for how to connect.

PING=0
echo "Waiting for connection..."
while [ $PING = 0 ];
do
    sleep 3;
    IP=$(env LIBVIRT_DEFAULT_URI="qemu:///system" virsh net-dhcp-leases --network default \
        | grep $NAME | sed "s/\ /+/g" | cut -d"+" -f16 | cut -d'/' -f1);
    echo $IP
    TESTPING=$(ping -c 1 $IP | grep 100%);
    if [ "$TESTPING" != "" ] ; then
        echo "..."
    else
        PING=1;
        echo -e "Deployment successful! try connecting with:\nssh -i $SSHKEYFILE $USER@$IP"
    fi
done
