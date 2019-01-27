#!/bin/bash
# Download kvm images

imagename="debian7 debian8 centos7 centos7.5 ubuntu1604 ubuntu1804 metasploitable kali arch"
image="$1.qcow2"
url=http://get.goffinet.org/kvm/
destination=/var/lib/libvirt/images/
parameters=$#
wd=$PWD

if [ ${parameters} -ne 1 ]; then
echo "Please provide the image name : "
echo ${imagename}
exit
fi
if [ ! -f ${destination}${image}  ] ; then
echo "The image ${destination}${image} does not exist."
echo "Do you want download this file ${image}"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        sleep1
        ;;
    *)
        exit
        ;;
esac
fi
wget ${url}${image} -O ${destination}${image}
wget ${url}${image}.sha1 -O ${destination}${image}.sha1
cd ${destination}
sha1sum -c ${image}.sha1
cd ${wd}
