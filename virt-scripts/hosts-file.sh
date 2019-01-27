#!/bin/bash

debian8_list() {
for name in $(virsh list --name); do
mac=$(virsh dumpxml ${name}|grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g")
ip=$(grep $mac /var/lib/libvirt/dnsmasq/default.leases | awk '{print $3}')
echo "$ip $name" #>> /etc/hosts
done
}

centos7_list() {
for name in $(virsh list --name); do
mac=$(virsh dumpxml ${name}|grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g")
ip=$(grep $mac /var/log/messages | tail -n 1 | awk '{print $7}')
echo "$ip $name" #>> /etc/hosts
done
}

if [ -f /etc/debian_version ]; then
debian8_list
elif [ -f /etc/redhat-release ]; then
centos7_list
fi
