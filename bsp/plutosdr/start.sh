#!/bin/sh

# This file is part of LeanTRX (c) <pabr@pabr.org>.
# See the toplevel README for more information.

# If the USB drive is present at boot time, occasionally this script
# gets called before sethostname and the platform detection fails.
# Add a delay to avoid this.
case $(uname -a) in
    Linux*none*) sleep 2 ;;
esac

case $(uname -a) in
    Linux\ pluto\ *\ armv7l\ *) ;;
    *) echo "PlutoSDR platform not recognized, aborting."; exit 1 ;;
esac

# For ssh
PATH=/sbin:$PATH

KV=$(cat /proc/version  |  sed -e 's/Linux version \([0-9.]*\).*/\1/')

echo "Enabling RNDIS HOST for kernel $KV."
insmod $KV/cdc_ether.ko
insmod $KV/rndis_host.ko

INTERFACES=/etc/network/interfaces
if ! grep -q usb1 $INTERFACES; then
    cat  >> $INTERFACES  <<EOF
auto usb1
iface usb1 inet static
	address 192.168.42.42
	netmask 255.255.255.0
EOF
fi  

install_from_cwd() {
    # Flash the LED during installation
    local LED=/sys/class/leds/led0:green
    echo timer  > $LED/trigger
    echo 50  > $LED/delay_on
    echo 50  > $LED/delay_off
    
    rm -rf /www/leantrx
    ln -s $PWD/html /www/leantrx

    rm -rf /www/cgi-bin/leantrx
    mkdir -p /www/cgi-bin
    ln -s $PWD/cgi-bin /www/cgi-bin/leantrx

    rm -f /etc/avahi/services/leantrx.service
    ln -s $PWD/bsp/plutosdr/avahi.service /etc/avahi/services/leantrx.service
    /etc/init.d/S50avahi-daemon reload

    sleep 1
    echo heartbeat  > $LED/trigger
}

run_from_usbdisk() {
    cd ../..
    install_from_cwd
}

run_from_ramdisk() {
    cd ../../..
    cp -a leantrx /tmp
    cd /tmp/leantrx
    install_from_cwd
}

case "$1" in
    usbdisk) run_from_usbdisk ;;
    ramdisk) run_from_ramdisk ;;
    *)
	if ifconfig eth0 > /dev/null; then
	    # Assume USB HUB present and the disk will remain connected.
	    run_from_usbdisk
	else
	    # Assume the USB disk will be unplugged.
	    run_from_ramdisk
	fi
	;;
esac
