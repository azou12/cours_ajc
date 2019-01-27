#!/bin/bash
# vm-install4.sh

bridge=192.168.122.1
mirror=http://$bridge/repo
#mirror=http://centos.mirrors.ovh.net/ftp.centos.org/7/os/x86_64
#mirror=http://ftp.belnet.be/ftp.centos.org/7/os/x86_64
#mirror=http://mirror.i3d.net/pub/centos/7/os/x86_64

#Stop and undefine the VM
/bin/virsh destroy $1; /bin/virsh undefine $1 --remove-all-storage

# Text console, bridged, HD qcow2
# HTTP + Kickstart 
virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.qcow2,size=16,format=qcow2 \
--ram=1024 \
--vcpus=1 \
--os-variant=rhel7 \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "ks=http://$bridge/conf/vm2.ks console=ttyS0,115200n8 serial"
