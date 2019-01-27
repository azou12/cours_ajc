#!/bin/bash

#file=/var/www/html/conf/debian8-preseed.cfg
#url=http://gist.githubusercontent.com/goffinet/e2d4b7d7ce004610998523c1b81452ad/raw/bc3bda58f8440bf7c1630c9618a34d2141d0fa82/debian8-preseed.cfg
url=http://192.168.122.1/conf/ubuntu1604-preseed.cfg
mirror=http://mirror.ovh.net/ubuntu/dists/xenial/main/installer-amd64/

virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.qcow2,size=8,format=qcow2 \
--ram=512 \
--vcpus=1 \
--os-variant=ubuntu16.04 \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "auto=true hostname=$1 domain= url=$url text console=ttyS0,115200n8 serial"
