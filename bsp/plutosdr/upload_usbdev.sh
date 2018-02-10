#!/bin/sh

# Upload and run leantrx on PlutoSDR connected as USB device.

PLUTOSDR=192.168.2.1

scp -r ../../. root@$PLUTOSDR:/tmp/leantrx

ssh root@$PLUTOSDR "cd /tmp/leantrx/bsp/plutosdr; ./start.sh"
