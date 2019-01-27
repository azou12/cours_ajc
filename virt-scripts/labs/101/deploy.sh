#!/bin/bash
name="101"
cd labs/${name}
virsh destroy pc1-${name}
virsh destroy r${name}
#virt-customize -d r${name} --upload router-firewall.sh:/root/router-firewall.sh 
virt-customize -d r${name} --firstboot 'router-firewall.sh'
