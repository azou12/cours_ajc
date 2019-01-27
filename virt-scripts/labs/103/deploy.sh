#!/bin/bash
name="103"
cd labs/${name}
for x in 1 2 3 4 ; do
virsh destroy r${x}-${name}
mac=$(tr -dc a-f0-9 < /dev/urandom | head -c 10 | sed -r 's/(..)/\1:/g;s/:$//;s/^/02:/')
virsh attach-interface r${x}-${name} --type bridge --source virbr0 --model virtio --mac $mac --config
sed -i "s/id='[1-4]'/id='$x'/" init.sh
#virt-customize -d r${x}-${name} --upload init.sh:/root/init.sh 
virt-customize -d r${x}-${name} --firstboot 'init.sh'
virsh start r${x}-${name}

done 
