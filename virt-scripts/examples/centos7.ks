install
reboot
rootpw --plaintext testtest
keyboard --vckeymap=be-oss --xlayouts='be (oss)'
timezone Europe/Paris --isUtc
#timezone Europe/Brussels
lang en_US.UTF-8
#lang fr_BE
#cdrom
url --url="http://centos.mirrors.ovh.net/ftp.centos.org/7/os/x86_64"
firewall --disabled
network --bootproto=dhcp --device=eth0
network --bootproto=dhcp --device=eth1
network --hostname=c1
# network --device=eth0 --bootproto=static --ip=192.168.22.10 --netmask 255.255.255.0 --gateway  --nameserver= --ipv6 auto
#auth  --useshadow  --passalgo=sha512
text
firstboot --enable
skipx
ignoredisk --only-use=vda
bootloader --location=mbr --boot-drive=vda
zerombr
clearpart --all --initlabel
#autopart --type=thinp # See the bug resolved in 7.3 https://bugzilla.redhat.com/show_bug.cgi?id=1290755
autopart --type=lvm
#part /boot --fstype="xfs" --ondisk=vda --size=500
#part swap --recommended
#part pv.00 --fstype="lvmpv" --ondisk=vda --size=500 --grow
#volgroup local0 --pesize=4096 pv.00
#logvol /  --fstype="xfs"  --size=4000 --name=root --vgname=local0
%packages
@core
wget
%end
%post
yum -y update && yum -y upgrade
#mkdir /root/.ssh
#curl /id_rsa.pub > /root/.ssh/authorized_keys
#sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
%end
