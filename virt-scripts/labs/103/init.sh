#!/bin/bash
## Check Variables
id='4'
connectionlan="System eth0"
connectionwan="Wired connection 1"
ip4="10.103"
ip6="fd00:103"
lan="eth0"
wan="eth1"
domain="lab$id"

1a_interfaces () {
#hostnamectl set-hostname router
nmcli c mod "$connectionlan" ipv4.addresses ${ip4}.${id}.1/24
nmcli c mod "$connectionlan" ipv4.method manual
nmcli c mod "$connectionlan" ipv6.addresses ${ip6}:${id}::1/64
nmcli c mod "$connectionlan" ipv6.method manual
nmcli c mod "$connectionlan" connection.zone internal
nmcli c up  "$connectionlan"
nmcli c mod "$connectionwan" ipv4.addresses ${ip4}.0.${id}/24
nmcli c mod "$connectionwan" ipv4.method manual
nmcli c mod "$connectionwan" ipv6.addresses ${ip6}::${id}/64
nmcli c mod "$connectionwan" ipv6.method manual
nmcli c mod "$connectionwan" connection.zone internal
nmcli c up  "$connectionwan"
}

2_routing () {
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -p
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
#Routing BCP to implement
}

3_firewall () {
systemctl disable firewalld
systemctl stop firewalld
systemctl mask firewalld
systemctl disable iptables
systemctl disable ip6tables
systemctl stop iptables
systemctl stop ip6tables
}

4_dhcp-dns () {
yum -y install dnsmasq*
echo "domain=${domain}" > /etc/dnsmasq.d/eth0.conf
echo "dhcp-range=${ip4}.${id}.50,${ip4}.${id}.150,255.255.255.0,12h" >> /etc/dnsmasq.d/eth0.conf
echo "dhcp-option=3,${ip4}.1" >> /etc/dnsmasq.d/eth0.conf
echo "dhcp-range=${ip6}:${id}::,ra-stateless,ra-names" >> /etc/dnsmasq.d/eth0.conf
systemctl enable dnsmasq
systemctl start dnsmasq
}

5_selinux_configuration () {
sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/sysconfig/selinux
#sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
cat /.autorelabel ; reboot
}

ospf () {
yum -y install quagga
cat << EOF > /etc/quagga/ospfd.conf
router ospf
 ospf router-id ${id}.${id}.${id}.${id}
 passive-interface eth0
 network ${ip4}.0.0/24 area 0.0.0.0
 network ${ip4}.${id}.0/24 area 0.0.0.0
EOF
chown quagga:quagga /etc/quagga/ospfd.conf
cat << EOF > /etc/quagga/ospf6d.conf
interface eth0
 ipv6 ospf6 passive
 ipv6 ospf6 priority 1
interface eth1
 ipv6 ospf6 priority 1
router ospf6
 router-id ${id}.${id}.${id}.${id}
 interface eth0 area 0.0.0.0
 interface eth1 area 0.0.0.0
EOF
chown quagga:quagga /etc/quagga/ospf6d.conf
setsebool -P zebra_write_config 1
systemctl enable zebra
systemctl start zebra
systemctl enable ospfd
systemctl start ospfd
systemctl enable ospf6d
systemctl start ospf6d
}

management_network_down () {
nmcli c mod "Wired connection 2" ipv4.method disabled
nmcli c mod "Wired connection 2" ipv6.method ignore
nmcli c down "Wired connection 2"
}


## lan and wan interface configuration with NetworkManager 
1a_interfaces
## IPv4/IPv6 Routing
2_routing
## Firewall configuration (disabled)
3_firewall
## DHCP, DHCPv6, SLAAC, DNS Service
4_dhcp-dns
## OSPF Configuration
ospf
## Selinux configuration stuff (disabled)
#selinux_configuration
## Disabling eth2 management interface
management_network_down
