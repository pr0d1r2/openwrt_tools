#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/.shared.sh

run opkg install usbutils kmod-usb-storage block-mount
run mkdir /mnt/extstorage

run 'grep -q /mnt/extstorage /etc/config/fstab'
if [ $? -gt 0 ]; then
  run 'echo "config mount" >> /etc/config/fstab'
  run 'echo "        option target /mnt/extstorage" >> /etc/config/fstab'
  run 'echo "        option device /dev/sda" >> /etc/config/fstab'
  run 'echo "        option enabled 1" >> /etc/config/fstab'
  run 'echo "        option enabled_fsck 0" >> /etc/config/fstab'
fi

run /etc/init.d/fstab enable
run /sbin/block mount
