# File /var/www/html/conf/vm2.ks
#platform=x86, AMD64, ou Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
# old format: keyboard be-latin1
# new format:
keyboard --vckeymap=be-oss --xlayouts='be (oss)'
# Reboot after installation
reboot
# Root password
rootpw --plaintext testtest
# System timezone
timezone Europe/Paris
# System language
lang fr_BE
# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=link
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use text mode install
text
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx

# System services
services --enabled="chronyd"

bootloader --location=mbr --boot-drive=vda
clearpart --all --initlabel --drives=vda
ignoredisk --only-use=vda
part pv.0 --fstype="lvmpv" --ondisk=vda --size=5000
part /boot --fstype="xfs" --ondisk=vda --size=500
volgroup vg0 --pesize=4096 pv.0
logvol swap  --fstype="swap" --size=500 --name=swap --vgname=vg0
logvol /  --fstype="xfs" --size=3072 --name=root --vgname=vg0

%packages --ignoremissing
@core
chrony

%end
