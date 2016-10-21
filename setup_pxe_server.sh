#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/setup_external_storage.sh
source $D_R/setup_wget_with_ssl.sh

run mkdir /mnt/extstorage/tftp /mnt/extstorage/tftp/pxelinux.cfg /mnt/extstorage/tftp/disks /mnt/extstorage/tftp/disks/ubuntu1310-64
run opkg install tar

run mkdir /mnt/extstorage/syslinux-download


SYSLINUX_TGZ='/mnt/extstorage/syslinux-download/syslinux-6.02.tar.gz'
run "test -f $SYSLINUX_TGZ"
if [ $? -gt 0 ]; then
  run wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.02.tar.gz -O $SYSLINUX_TGZ
fi

SYSLINUX_PATH='/mnt/extstorage/syslinux-download/syslinux-6.02'
run "test -d $SYSLINUX_PATH"
if [ $? -gt 0 ]; then
  run tar -xf $SYSLINUX_TGZ -C /mnt/extstorage/syslinux-download
fi

for FILE in \
  $SYSLINUX_PATH/bios/core/pxelinux.0 \
  $SYSLINUX_PATH/bios/com32/elflink/ldlinux/ldlinux.c32 \
  $SYSLINUX_PATH/bios/com32/menu/vesamenu.c32 \
  $SYSLINUX_PATH/bios/com32/lib/libcom32.c32 \
  $SYSLINUX_PATH/bios/com32/libutil/libutil.c32 \

do
  run cp $FILE /mnt/extstorage/tftp
done

run 'grep "^MENU TITLE OpenWRT PXE-Boot Menu$" /mnt/extstorage/tftp/pxelinux.cfg/default'
if [ $? -gt 0 ]; then
  run 'echo "DEFAULT vesamenu.c32" > /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "PROMPT 0" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
  run 'echo "MENU TITLE OpenWRT PXE-Boot Menu" >> /mnt/extstorage/tftp/pxelinux.cfg/default'
fi

run opkg install kmod-loop kmod-fs-isofs rsync


run "uci set dhcp.@dnsmasq[0].enable_tftp='1'"
run "uci set dhcp.@dnsmasq[0].tftp_root='/mnt/extstorage/tftp'"
run "uci commit"

run "uci set dhcp.linux='boot'"
run "uci set dhcp.linux.filename='pxelinux.0'"
run "uci set dhcp.linux.serveraddress='192.168.1.1'"
run "uci set dhcp.linux.servername='OpenWRT'"
run "uci commit"

run "/etc/init.d/dnsmasq restart"

run 'opkg install nfs-kernel-server'

run 'echo "/mnt/extstorage/tftp/disks  *(ro,async,no_subtree_check)" > /etc/exports'

run '/etc/init.d/portmap enable'
run '/etc/init.d/portmap restart'
run '/etc/init.d/nfsd enable'
run '/etc/init.d/nfsd restart'
