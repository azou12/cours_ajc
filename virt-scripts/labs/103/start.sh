#!/bin/bash
name="103"

start_time="$(date -u +%s)"

for x in lan1 lan2 lan3 lan4 wan ; do 
virsh net-destroy $x${name} ; virsh net-undefine $x${name}
./add-bridge.sh ${x}-${name} isolated
done

for x in r pc ; do virsh destroy $x${name} ; virsh undefine $x${name} --remove-all-storage ; done

for x in 1 2 3 4 ; do
for y in r pc ; do
virsh destroy ${y}${x}-${name} ; virsh undefine ${y}${x}-${name} --remove-all-storage
./deploy-image-by-profile.sh ${y}${x}-${name} lan${x}-${name} xsmall ; done
./add-nic.sh r${x}-${name} wan-${name}
done

end_time="$(date -u +%s)"
echo "Time elapsed $(($end_time-$start_time)) second"
