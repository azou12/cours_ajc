#!/bin/bash
# vm-install2.sh

# KVM Host IP
bridge=192.168.122.1

# Repo URL
#mirror=http://$bridge/repo
#mirror=http://centos.mirrors.ovh.net/ftp.centos.org/7/os/x86_64
#mirror=http://ftp.belnet.be/ftp.centos.org/7/os/x86_64
#mirror=http://mirror.i3d.net/pub/centos/7/os/x86_64
mirror=http://centos.mirrors.ovh.net/ftp.centos.org/6.9/os/x86_64/
os="rhel6"

# Stop and undefine the VM
/bin/virsh destroy $1; /bin/virsh undefine $1 --remove-all-storage

# graphical console, bridged
# via http repo
virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.img,size=8 \
--ram=1024 \
--vcpus=1 \
--os-variant=$os \
--network bridge=virbr0 \
--graphics vnc \
--console pty,target_type=serial \
--location $mirror
