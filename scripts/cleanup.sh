#!/bin/sh

. ./defaults.ini

virsh shutdown $NAME
virsh destroy --domain $NAME
virsh undefine --nvram --domain $NAME
rm -rf ./$NAME
rm -f ./creds/$NAME*
