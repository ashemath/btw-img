#!/bin/sh

if [ $1 = '-c' ] && [ -f $2 ] ; then
    echo "loading config from $2";
    . $2;
fi

if [ ! -z $POSTINIT ] ; then
    echo "Post-init detected! $POSTINIT";
fi


## Wait for the IP address to update in libvirt's DHCP service
## display helpful suggestion for how to connect.

PING=0
IP="Not Found...yet..."
echo "Waiting for connection..."
sleep 1;
while [ $PING = 0 ];
do
    IP=$(dig $NAME @192.168.122.1 | grep ".*IN.*A.*192.168.122" | sed "s/\t//g" | sed "s/INA/+/g" | cut -d"+" -f2);
    echo "IP is set to: $IP";
    TESTPING=$(ping -c 1 $IP | grep " 0%");
    if [ -z "$TESTPING" ] ; then
        echo "..."
    else
        PING=1;
        sshfile="creds/$NAME.ssh"
        echo "ssh -i $SSHKEYFILE -o StrictHostKeyChecking=no $USER@$IP" \
            | tee | tail -n 1 > $sshfile;
        chmod 700 $sshfile;
        sleep 2;
    fi
done
if [ ! -z $POSTINIT ] ; then
    echo "Running postinit!"
    sleep 2;
    cat $POSTINIT | ./$sshfile;
fi

