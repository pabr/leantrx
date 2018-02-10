#!/bin/sh

# Copy this script and /etc/dropbear/dropbear_ecdsa_host_key
# to the root of the USB Mass Storage device if you want to
# prevent "REMOTE HOST IDENTIFICATION HAS CHANGED" from ssh.

rm /etc/dropbear  &&  mkdir /etc/dropbear
cp /media/$MDEV/dropbear_ecdsa_host_key /etc/dropbear/
