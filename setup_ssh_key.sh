#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/.shared.sh

if [ ! -f $HOME/.ssh/id_rsa_$HOSTNAME ]; then
  # Maximum for now it 2k
  echorun ssh-keygen -b 2048 -f $HOME/.ssh/id_rsa_$HOSTNAME -C $HOSTNAME@`hostname` -o -a 1000 || return $?
fi
echorun scp $HOME/.ssh/id_rsa_$HOSTNAME.pub root@$HOSTNAME:/tmp/authorized_keys || return $?
run 'cat /tmp/authorized_keys >> /etc/dropbear/authorized_keys'

cat $HOME/.ssh/config | grep -q "^Host $HOSTNAME$"
if [ $? -gt 0 ]; then
  echo "Host $HOSTNAME" >> $HOME/.ssh/config
  echo "  IdentityFile ~/.ssh/id_rsa_$HOSTNAME" >> $HOME/.ssh/config
fi

ssh-add ~/.ssh/id_rsa_$HOSTNAME
