#!/bin/bash
## Check Variables
connection="System eth0"
ip4="192.168.168"
ip6="fd00:168:168"
lan="eth0"
wan="eth1"

1a_interfaces () {
#hostnamectl set-hostname router
nmcli c mod "$connection" ipv4.addresses $ip4.1/24
nmcli c mod "$connection" ipv4.method manual
nmcli c mod "$connection" ipv6.addresses $ip6::1/64
nmcli c mod "$connection" ipv6.method manual
nmcli c mod "$connection" connection.zone internal
nmcli c up  "$connection"
}

1b_interfaces () {
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
NM_CONTROLLED="no"
ONBOOT="yes"
IPV6INIT="yes"
BOOTPROTO="static"
IPADDR="${ip4}.1"
NETMASK="255.255.255.0"
IPV6ADDR="${ip6}::1/64"
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
NM_CONTROLLED="no"
IPV6INIT="yes"
ONBOOT="yes"
BOOTPROTO="dhcp"
EOF
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl restart network
}

2_routing () {
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -p
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
#Routing BCP to implement
}

3a_firewall () {
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=internal --add-service=dns --permanent
firewall-cmd --zone=internal --add-service=dhcp --permanent
firewall-cmd --zone=internal --add-service=dhcpv6 --permanent
firewall-cmd --zone=internal --add-source=${ip4}.0/24 --permanent
firewall-cmd --zone=internal --add-source=${ip6}::/64 --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload
}

3b_firewall () {
#Disable Firewalld / Install iptables-services
systemctl disable firewalld
systemctl stop firewalld
systemctl mask firewalld
yum install -y iptables-services
#Start IPv4 Firewall Configuration
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o $wan -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i $lan -j ACCEPT
iptables -A OUTPUT -o $lan -j ACCEPT
iptables -A FORWARD -m state --state NEW -i $lan -o $wan -s ${ip4}.0/24 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -i $wan --sport 67 -j ACCEPT
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP
iptables -t nat -A POSTROUTING -s ${ip4}.0/24 -o $wan -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
##Start IPv6 Firewall Configuration
ip6tables -F
ip6tables -X
ip6tables -A INPUT  -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -o $wan -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -i $lan -j ACCEPT
ip6tables -A OUTPUT -o $lan -j ACCEPT
ip6tables -A INPUT -m rt --rt-type 0 -j DROP
ip6tables -A FORWARD -m rt --rt-type 0 -j DROP
ip6tables -A OUTPUT -m rt --rt-type 0 -j DROP
ip6tables -A INPUT -s fe80::/10 -j ACCEPT
ip6tables -A OUTPUT -s fe80::/10 -j ACCEPT
ip6tables -A INPUT -d ff00::/8 -j ACCEPT
ip6tables -A OUTPUT -d ff00::/8 -j ACCEPT
ip6tables -I INPUT  -p icmpv6 -j ACCEPT
ip6tables -I OUTPUT -p icmpv6 -j ACCEPT
ip6tables -I FORWARD -p icmpv6 -j ACCEPT
ip6tables -A FORWARD -m state --state NEW -i $lan -o $wan -s ${ip6}::/64 -j ACCEPT
ip6tables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m state --state NEW -m udp -p udp --dport 546 -d fe80::/64 -j ACCEPT
ip6tables -P INPUT   DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT  DROP
ip6tables-save > /etc/sysconfig/ip6tables
#Enable and start iptables-services
systemctl enable iptables
systemctl enable ip6tables
systemctl start iptables
systemctl start ip6tables
}

4_dhcp-dns () {
yum -y install dnsmasq*
echo "domain=$domain" > /etc/dnsmasq.d/eth0.conf
echo "dhcp-range=$ip4.50,$ip4.150,255.255.255.0,12h" > /etc/dnsmasq.d/eth0.conf
echo "dhcp-option=3,$ip4.1" >> /etc/dnsmasq.d/eth0.conf
echo "dhcp-range=$ip6::2,$ip6::500,slaac" >> /etc/dnsmasq.d/eth0.conf
systemctl enable dnsmasq
systemctl start dnsmasq
}

5_selinux_configuration () {
sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/sysconfig/selinux
#sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
cat /.autorelabel ; reboot
}

## lan and wan interface configuration with NetworkManager (disabled)
1a_interfaces
## lan and wan interface configuration with ifcfg files (enabled)
#1b_interfaces
## IPv4/IPv6 Routing
2_routing
## Firewall configuration with Firewalld (disabled)
3a_firewall
## Firewall configuration with Netfilter/Iptables (disabled)
#3b_firewall
## DHCP, DHCPv6, SLAAC, DNS Service
4_dhcp-dns
## Selinux configuration stuff (disabled)
#5_selinux_configuration
