#!/bin/sh

D_R=`cd \`dirname $0\` ; pwd -P`
source $D_R/.shared.sh

run opkg install wget

run mkdir -p /etc/ssl/certs
run 'grep -q "^export SSL_CERT_DIR=/etc/ssl/certs$" /etc/profile'
if [ $? -gt 0 ]; then
  run 'echo export SSL_CERT_DIR=/etc/ssl/certs >> /etc/profile'
fi

run opkg install ca-certificates
