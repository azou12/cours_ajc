# File /var/www/html/conf/vm.ks

keyboard --vckeymap=be-oss --xlayouts='be (oss)'
lang fr_BE.UTF-8
network --onboot=on --bootproto=dhcp --device=link --hostname=localhost.localdomain
rootpw testtest
services --enabled="chronyd"
timezone Europe/Paris --isUtc
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
reboot
