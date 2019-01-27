#!/bin/bash
name="101"
for x in lan wan ; do virsh net-destroy $x${name} ; virsh net-undefine $x${name} ; done
./add-bridge.sh lan${name} isolated
./add-bridge.sh wan${name} full
for x in r pc1- ; do virsh destroy $x${name} ; virsh undefine $x${name} --remove-all-storage ; done
./deploy-image-by-profile.sh r${name} lan${name} small
./add-nic.sh r${name} wan${name}
./deploy-image-by-profile.sh pc1-${name} lan${name} xsmall
