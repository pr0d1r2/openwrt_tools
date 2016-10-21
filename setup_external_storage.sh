#!/bin/sh

if [ -f .hostname ]; then
  HOSTNAME=`cat .hostname`
else
  HOSTNAME=$1
fi

case $HOSTNAME in
  "")
    echo "You must give hostname as first param or setup .hostname file!!!"
    return 8472
    ;;
esac

function echorun() {
  echo "$@"
  $@ || return $?
}

function run() {
  echorun ssh root@$HOSTNAME $@
}

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
