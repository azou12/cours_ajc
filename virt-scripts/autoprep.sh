#!/bin/bash
#Setup KVM/Libvirtd/LibguestFS on RHEL7/Centos 7/Debian Jessie.

check_distribution () {
if [ -f /etc/debian_version ]; then
debian8_prep
sudo virsh net-start default
sudo virsh net-autostart default
elif [ -f /etc/redhat-release ]; then
centos7_prep
fi
}

validation () {
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
       sleep 1 
        ;;
    *)
        exit
        ;;
esac
}

debian8_prep() {
echo " Upgrade the system"
apt-get -y install sudo
sudo apt-get update && sudo apt-get -y upgrade
echo "Virtualization host installation"
sudo apt-get -y install qemu-kvm libvirt-bin virtinst virt-viewer libguestfs-tools virt-manager uuid-runtime
#echo "kcli libvirt  wrapper installation"
sudo apt-get -y install python-pip pkg-config libvirt-dev genisoimage qemu-kvm netcat libvirt-bin python-dev libyaml-dev
#sudo pip install kcli
echo "Enabling Nested Virtualization"
rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
modprobe kvm-intel
cat /sys/module/kvm_intel/parameters/nested
}

centos7_prep() { 
echo " Upgrade the system"
sudo yum -y install epel-release
sudo yum -y upgrade
echo "Virtualization host installation"
sudo yum -y group install "Virtualization Host"
sudo yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer virt-manager
#echo "kcli libvirt  wrapper installation"
sudo yum -y install gcc libvirt-devel python-devel genisoimage qemu-kvm nmap-ncat python-pip
#sudo pip install kcli
echo "Enabling Nested Virtualization"
rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
modprobe kvm-intel
cat /sys/module/kvm_intel/parameters/nested
}

services_activation() {
echo "Activate all those services"
#sudo systemctl stop firewalld
sudo systemctl restart libvirtd
sudo virt-host-validate
}

check_apache () {
yum install -y httpd curl || apt-get -y install apache2 curl
#We do so despite it being disabled
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd || systemctl enable apache2
systemctl start httpd || systemctl start apache2
mkdir -p /var/www/html/conf
echo "this is ok" > /var/www/html/conf/ok
local check_value="this is ok"
local check_remote=$(curl -s http://127.0.0.1/conf/ok)
if [ "$check_remote"="$check_value" ] ; then
 echo "Apache is working"
else
 echo "Apache is not working"
 exit
fi
}

echo "This script will install all the necessary packages to use Libvirtd/KVM"
echo "Please reboot your host after this step"
validation
check_distribution
services_activation
check_apache
echo "Please verify the install report et reboot your host"
