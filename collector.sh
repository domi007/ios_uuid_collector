#!/bin/bash
# Copyright (c) Domonkos P. Tomcsanyi
# See LICENSE.txt


if [ "$EUID" -ne 0 ]
  then echo "Please run as root or via sudo $0"
  exit
fi

if [[ $# -lt 3 ]] || [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` OUTPUT_FILENAME DEVICE_NAME START_NUMBER"
  echo "The script will create the following output file:"
  echo "Each line starts with the constant string DEVICE_NAME with the START_NUMBER appended and incremented with each device connected"
  exit 0
fi
DEVICE_NAME=$2
START_NUMBER=$3
CONNECTED=false
tail -n0 -F /var/log/kern.log | \
while read LINE
do
  if [ "$CONNECTED" = true ] ; then
    ID=$(echo "$LINE" | grep -o -P '(?<=SerialNumber: )[A-Za-z0-9]*')
    #appending 0s to the
    printf -v padded "%05d" $START_NUMBER
    echo "$ID  $DEVICE_NAME$padded" >> $1
    echo "iOS Device captured, conect next one"
    CONNECTED=false
    START_NUMBER=$((START_NUMBER+1))
  fi

  if echo "$LINE" | grep 'Manufacturer: Apple Inc.'  1>/dev/null 2>&1; then
    CONNECTED=true
  fi
done
