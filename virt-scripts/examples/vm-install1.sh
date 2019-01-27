#!/bin/bash
# vm-install1.sh

# local path to the iso
iso=/var/lib/iso/CentOS-7-x86_64-DVD-1611.iso

# Stop and undefine the VM
/bin/virsh destroy $1; /bin/virsh undefine $1 --remove-all-storage

# graphical console
# via local ISO 
virt-install \
--virt-type kvm \
--name=$1 \
--disk path=/var/lib/libvirt/images/$1.img,size=8 \
--ram=1024 \
--vcpus=1 \
--os-variant=rhel7 \
--graphics vnc \
--console pty,target_type=serial \
--cdrom $iso
