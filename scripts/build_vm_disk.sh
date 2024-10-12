#!/bin/sh

NAME="test"
DIR="./$NAME"

if [ ! -d $DIR ] ; then
mkdir $DIR;
fi

cp ./images/latest/disk.qcow2 $DIR/

cd $DIR;
qemu-img create -f qcow2 -o backing_file="disk.qcow2" test.qcow2 -F qcow2 10G
