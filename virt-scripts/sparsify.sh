#!/bin/bash
#This script sparses an attached disk
#The guest must be shutdown 
#Great gain on disk space !
name=$1

check_guest_name () {
if [ -z "${name}" ]; then
echo "This script sparses an attached disk"
echo "Please provide a the guest name of a destroyed guest: exit"
echo "Usage : $0 <guest name>"
exit
fi
if grep -qvw "$name" <<< $(virsh list --all --name)  ; then
echo "Please provide a defined guest name : exit"
echo "Guests avaible : "
echo "$(virsh list --all --name)"
echo "Usage : $0 <guest name>"
exit
fi
}

sparsify ()
{
echo "stop guest OS"
virsh destroy $name 2> /dev/null
echo "Sparse disk optimization"
# make a virtual machine disk sparse
virt-sparsify --check-tmpdir ignore --compress --convert qcow2 --format qcow2 /var/lib/libvirt/images/$name.qcow2 /var/lib/libvirt/images/$name-sparsified.qcow2
# remove original image
rm -rf /var/lib/libvirt/images/$name.qcow2
# rename sparsified
mv /var/lib/libvirt/images/$name-sparsified.qcow2 /var/lib/libvirt/images/$name.qcow2
# set correct ownership for the VM image file
#chown qemu:qemu /var/lib/libvirt/images/$name.qcow2
}

sysprep () {
echo "Sysprep"
virt-sysprep -d $name --hostname $name --selinux-relabel
}

check_guest_name
sysprep
sparsify
