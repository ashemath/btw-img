#!/bin/sh

. conf.d/default.conf;
if [ $1 = '-c' ] ; then
    echo "loading config from $2";
    . $2;
fi

if [ -f  conf.d/$NAME.sh ] ; then
    postinit="conf.d/$NAME.sh"
    echo "Post-init detected! $postinit"
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
        sleep 1;
        cat $postinit | $sshfile;
    fi
    sleep 2;
done
