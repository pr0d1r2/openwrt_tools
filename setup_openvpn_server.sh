#!/bin/sh

D_R=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck disable=SC1090,2039
source "$D_R/.shared.sh" || exit $?

run "opkg install openvpn-openssl openvpn-easy-rsa"

run build-ca
run build-dh
run "build-key-server my-server"
run "build-key-pkcs12 my-client"
run "cp /etc/easy-rsa/keys/ca.crt /etc/easy-rsa/keys/my-server.* /etc/easy-rsa/keys/dh2048.pem /etc/openvpn"

run "uci set network.vpn0=interface"
run "uci set network.vpn0.ifname=tun0"
run "uci set network.vpn0.proto=none"
run "uci set network.vpn0.auto=1"

run "uci set firewall.Allow_OpenVPN_Inbound=rule"
run "uci set firewall.Allow_OpenVPN_Inbound.target=ACCEPT"
run "uci set firewall.Allow_OpenVPN_Inbound.src=*"
run "uci set firewall.Allow_OpenVPN_Inbound.proto=udp"
run "uci set firewall.Allow_OpenVPN_Inbound.dest_port=1194"

run "uci set firewall.vpn=zone"
run "uci set firewall.vpn.name=vpn"
run "uci set firewall.vpn.network=vpn0"
run "uci set firewall.vpn.input=ACCEPT"
run "uci set firewall.vpn.forward=REJECT"
run "uci set firewall.vpn.output=ACCEPT"
run "uci set firewall.vpn.masq=1"

run "uci set firewall.vpn_forwarding_lan_in=forwarding"
run "uci set firewall.vpn_forwarding_lan_in.src=vpn"
run "uci set firewall.vpn_forwarding_lan_in.dest=lan"

run "uci set firewall.vpn_forwarding_lan_out=forwarding"
run "uci set firewall.vpn_forwarding_lan_out.src=lan"
run "uci set firewall.vpn_forwarding_lan_out.dest=vpn"

run "uci set firewall.vpn_forwarding_wan=forwarding"
run "uci set firewall.vpn_forwarding_wan.src=vpn"
run "uci set firewall.vpn_forwarding_wan.dest=wan"

run "uci commit network"
run "/etc/init.d/network reload"
run "uci commit firewall"
run "/etc/init.d/firewall reload"

run "echo > /etc/config/openvpn" # clear the openvpn uci config
run "uci set openvpn.myvpn=openvpn"
run "uci set openvpn.myvpn.enabled=1"
run "uci set openvpn.myvpn.verb=3"
run "uci set openvpn.myvpn.port=1194"
run "uci set openvpn.myvpn.proto=udp"
run "uci set openvpn.myvpn.dev=tun"
run "uci set openvpn.myvpn.server='10.8.0.0 255.255.255.0'"
run "uci set openvpn.myvpn.keepalive='10 120'"
run "uci set openvpn.myvpn.ca=/etc/openvpn/ca.crt"
run "uci set openvpn.myvpn.cert=/etc/openvpn/my-server.crt"
run "uci set openvpn.myvpn.key=/etc/openvpn/my-server.key"
run "uci set openvpn.myvpn.dh=/etc/openvpn/dh2048.pem"
run "uci commit openvpn"

run "/etc/init.d/openvpn enable"
run "/etc/init.d/openvpn start"
