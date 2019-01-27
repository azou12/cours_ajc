#!/bin/bash

name=$1
fr_debian_mirror=http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/
ovh_debian_mirror=http://debian.mirrors.ovh.net/debian/dists/wheezy/main/installer-amd64/
belnet_debian_mirror=http://ftp.belnet.be/debian/dists/wheezy/main/installer-amd64/
mirror=$fr_debian_mirror

virt-install \
--virt-type kvm \
--name=$name \
--disk path=/var/lib/libvirt/images/$name.qcow2,size=8,format=qcow2 \
--ram=512 \
--vcpus=1 \
--os-variant=debianwheezy \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "console=ttyS0,115200n8 serial"
