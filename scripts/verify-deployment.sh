#!/bin/sh

#if [ -z $1 ] ; then
#    echo "loading default.ini"
#    . ./default.ini;
#else
#    if [ $1 = '-c' ] ; then
#        echo "loading config from $2";
#        . ./$2;
#    fi
#fi


## Wait for the IP address to update in libvirt's DHCP service
## display helpful suggestion for how to connect.

PING=0
IP="Not Found...yet..."
echo "Waiting for connection..."
while [ $PING = 0 ];
do
    sleep 3;
    TESTPING=$(ping -c 1 $NAME 2> /dev/null | grep " 0%");
    if [ -z "$TESTPING" ] ; then
        echo "..."
    else
        PING=1;
        IP=$(host $NAME | head -n1 | cut -d" " -f4)
        echo -e "Deployment successful! try connecting with:\nssh -i $SSHKEYFILE -o StrictHostKeyChecking=no $USER@$IP"
    fi
done
