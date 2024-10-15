#!/bin/sh

. configs/default.ini;
if [ $1 = '-c' ] ; then
    echo "loading config from $2";
    . $2;
fi


## Wait for the IP address to update in libvirt's DHCP service
## display helpful suggestion for how to connect.

PING=0
IP="Not Found...yet..."
echo "Waiting for connection..."
while [ $PING = 0 ];
do
    sleep 3;
    echo "NAME is $NAME"
    IP=$(dig $NAME @192.168.122.1 | grep ".*IN.*A.*192.168.122" | sed "s/\t//g" | sed "s/INA/+/g" | cut -d"+" -f2);
    echo "IP is set to: $IP";
    TESTPING=$(ping -c 1 $IP | grep " 0%" 2>/dev/null);
    if [ -z "$TESTPING" ] ; then
        echo "..."
    else
        PING=1;
        echo -e "Deployment successful! try connecting with:\nssh -i $SSHKEYFILE -o StrictHostKeyChecking=no $USER@$IP"
    fi
    sleep 1;
done
