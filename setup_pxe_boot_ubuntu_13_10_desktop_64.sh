#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/setup_pxe_server.sh

run 'grep -q "^label Ubuntu Live 13.10 64-Bit$" /mnt/extstorage/tftp/pxelinux.cfg/default'
if [ $? -gt 0 ]; then
  run 'echo "label Ubuntu Live 13.10 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        MENU LABEL Ubuntu Live 13.10 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        KERNEL disks/ubuntu1310-64/casper/vmlinuz.efi" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  # TODO: unify 192.168.1.1 address to config one
  run 'echo "        APPEND boot=casper ide=nodma netboot=nfs nfsroot=192.168.1.1:/mnt/extstorage/tftp/disks/ubuntu1310-64/ initrd=disks/ubuntu1310-64/casper/initrd.lz" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        TEXT HELP" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "                Starts the Ubuntu Live-CD - Version 13.10 64-Bit" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "        ENDTEXT" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
fi

UBUNTU_DOWNLOAD_PATH="/mnt/extstorage/ubuntu-13-10-download"
run mkdir -p $UBUNTU_DOWNLOAD_PATH


UBUNTU_FILE='ubuntu-13.10-desktop-amd64.iso'
UBUNTU_CHECKSUM='21ec41563ff34da27d4a0b56f2680c4f'

UBUNTU_ISO="$UBUNTU_DOWNLOAD_PATH/$UBUNTU_FILE"
run "test -f $UBUNTU_ISO"
if [ $? -gt 0 ]; then
  run wget http://old-releases.ubuntu.com/releases/13.10/$UBUNTU_FILE -O $UBUNTU_ISO
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

run mkdir -p /mnt/extstorage/tftp/disks/ubuntu1310-64
run rsync -a /mnt/extstorage/iso-mount/ /mnt/extstorage/tftp/disks/ubuntu1310-64/

run umount /mnt/extstorage/iso-mount

run "/etc/init.d/dnsmasq restart"
