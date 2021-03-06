#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/setup_pxe_server.sh

run 'grep -q "^label Ubuntu Live 16.04 64-Bit$" /mnt/extstorage/tftp/pxelinux.cfg/default'
if [ $? -gt 0 ]; then
  run 'echo "label Ubuntu Live 16.04 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        MENU LABEL Ubuntu Live 16.04 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        KERNEL disks/ubuntu1604-64/casper/vmlinuz.efi" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  # TODO: unify 192.168.1.1 address to config one
  run 'echo "        APPEND boot=casper ide=nodma netboot=nfs nfsroot=192.168.1.1:/mnt/extstorage/tftp/disks/ubuntu1604-64/ initrd=disks/ubuntu1604-64/casper/initrd.lz" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        TEXT HELP" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "                Starts the Ubuntu Live-CD - Version 16.04 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        ENDTEXT" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
fi

UBUNTU_DOWNLOAD_PATH="/mnt/extstorage/ubuntu-16.04-download"
run mkdir -p $UBUNTU_DOWNLOAD_PATH


UBUNTU_FILE='ubuntu-16.04-desktop-amd64.iso'
UBUNTU_CHECKSUM='c94d54942a2954cf852884d656224186'

UBUNTU_ISO="$UBUNTU_DOWNLOAD_PATH/$UBUNTU_FILE"
run "test -f $UBUNTU_ISO"
if [ $? -gt 0 ]; then
  run wget http://releases.ubuntu.com/releases/16.04/$UBUNTU_FILE -O $UBUNTU_ISO
  run "rm -f $UBUNTU_DOWNLOAD_PATH/$UBUNTU_ISO.ok"
fi

run "test -f $UBUNTU_DOWNLOAD_PATH/$UBUNTU_ISO.ok"
if [ $? -gt 0 ]; then
  run "echo '$UBUNTU_CHECKSUM *$UBUNTU_ISO' > $UBUNTU_DOWNLOAD_PATH/MD5SUMS"
  run "md5sum -c $UBUNTU_DOWNLOAD_PATH/MD5SUMS"
  if [ $? -gt 0 ]; then
    echo "Malformed $UBUNTU_ISO. Removing ..."
    # TODO: uncomment after we are done
    # run rm -f $UBUNTU_ISO
    exit 8472
  else
    run "touch $UBUNTU_DOWNLOAD_PATH/$UBUNTU_ISO.ok"
  fi
fi

run mkdir -p /mnt/extstorage/iso-mount
run mount $UBUNTU_ISO /mnt/extstorage/iso-mount

run mkdir -p /mnt/extstorage/tftp/disks/ubuntu1604-64
run rsync -a /mnt/extstorage/iso-mount/ /mnt/extstorage/tftp/disks/ubuntu1604-64/

run umount /mnt/extstorage/iso-mount

run "/etc/init.d/dnsmasq restart"
