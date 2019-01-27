#!/bin/bash

url=http://ftp.belnet.be/ftp.centos.org/7/isos/x86_64/
iso=CentOS-7-x86_64-DVD-1511.iso
dir=/var/lib/iso
echo " Upgrade the system"
sudo yum -y upgrade
echo "Virtualization host installation"
sudo yum -y group install "Virtualization Host"
echo "Virtualisation tools installation"
sudo yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer
echo "Apache 2 installation"
sudo yum -y install httpd
echo "Activate all those services"
sudo systemctl stop firewalld
sudo systemctl restart libvirtd
sudo systemctl restart httpd
sudo mkdir -p /var/www/html/conf /var/www/html/repo
sudo chown apache:apache /var/www/html/conf /var/www/html/repo
sudo chcon -R -t httpd_sys_content_t /var/www/html
echo "Verify the iso directory"
if [ ! -e $dir  ]
then
    echo "Create $dir"
    sudo mkdir -p $dir
fi
echo "Verifiy the iso image"
while [ ! -f $dir/$iso ]; do
    echo "Image not present"
while true; do
    read -p "Do you wish to download this iso now (4Gb) from the Internet ?" yn
    case $yn in
        [Yy]* ) echo "sudo wget $url$iso";;
        [Nn]* ) echo "Please get this iso $iso"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
done
echo "Local and HTTP Repo"
sudo mount -o loop,ro $dir/$iso /var/www/html/repo
echo "Tests"
sudo ls -l $dir/$iso  
sudo curl -L http://127.0.0.1/repo | head | grep "Index of"
sudo virt-host-validate
