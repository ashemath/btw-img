#!/bin/sh
ARCHIVEPATH="/tmp/"
SERIAL="latest"
TYPE="generic";
PLATFORM="amd64";
IMAGE="debian-12-$TYPE-$PLATFORM";
ARCHIVE="$IMAGE.tar.xz";
IMAGEURL="https://cloud.debian.org/images/cloud/bookworm/$SERIAL/$ARCHIVE";

if [ ! -d "$ARCHIVEPATH/images/$SERIAL/" ] ; then
    echo "Subdirectory for $SERIAL not found. Creating...";
    mkdir -p $ARCHIVEPATH/images/$SERIAL/$IMAGE;
fi

echo "Fetching checksum reference file!"
wget https://cloud.debian.org/images/cloud/bookworm/$SERIAL/SHA512SUMS \
    -O $ARCHIVEPATH/images/$SERIAL/SHA512SUMS;

echo "Checking for $LATEST archive..."
if [ ! -e "$ARCHIVEPATH/images/$SERIAL/$ARCHIVE" ] ; then
    echo "Archive not found! Downloading...";
    wget $IMAGEURL -O $ARCHIVEPATH/images/$SERIAL/$ARCHIVE;
fi

SUM=$(sha512sum $ARCHIVEPATH/images/$SERIAL/$ARCHIVE | cut -d " " -f1);
CHECK=$(grep $(sha512sum $ARCHIVEPATH/images/$SERIAL/$ARCHIVE | \
    cut -d " " -f1) $ARCHIVEPATH/images/$SERIAL/SHA512SUMS | cut -d " " -f1);

echo "Check is: $CHECK";
echo "SUM os: $SUM";

if [ "$SUM" != "$CHECK"  ] ; then
    echo "Archive integrity check failed."
fi

echo "Archive verified. Extracting raw disk file..."

if [ ! -e "$ARCHIVEPATH/images/$SERIAL/disk.raw" ] ; then
  tar -xvf $ARCHIVEPATH/images/$SERIAL/$ARCHIVE -C $ARCHIVEPATH/images/$SERIAL/
fi

echo "Checking for .qcow image..."
if [ ! -e "$ARCHIVEPATH/images/$SERIAL/disk.qcow2" ] ; then
    echo "Converting $LATEST disk.raw to disk.qcow"
    qemu-img convert -O qcow2 $ARCHIVEPATH/images/$SERIAL/disk.raw $ARCHIVEPATH/images/$SERIAL/disk.qcow2;
fi

