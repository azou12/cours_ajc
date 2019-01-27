#!/bin/bash
# This script add a new NIC on live guest to a bridged interface 

guest=$1
bridge=$2
type="bridge"
model="virtio"
parameters=$#

check_parameters () {
# Check the numbers of parameters required
if [ "$parameters" -ne 2  ] ; then
echo "Description : This script add a new NIC on live guest to an interface" 
echo "Usage       : $0 <guest name> <bridge_interface_name>"
echo "Example     : '$0 guest1 virbr0' add the live guest1 NIC to virbr0"
echo "Example     : '$0 guest1 eth0' add the live guest1 NIC to eth0"
exit
fi
# Check if the guest name chosen is in live and display help to choose 
if grep -qvw "$guest" <<< $(virsh list --name)  ; then
echo "Please provide a live guest name : exit"
echo "Guests available :"
echo "$(virsh list --name)"
exit
fi
# Check if the bridge interface is avaible
if grep -qvw "$bridge" <<< $(ls /sys/class/net) ; then
echo "This interface ${bridge} is not available"
echo "Please create a valid bridge or choose between : "
echo $(ls /sys/class/net)
exit
fi
}

mac_address () {
mac=$(tr -dc a-f0-9 < /dev/urandom | head -c 10 | sed -r 's/(..)/\1:/g;s/:$//;s/^/02:/')
mac_param=" --mac $mac"
}


attach_nic () {
# Detach and attach the guest nic to the live guest
#virsh detach-interface $guest --type $type --source $bridge--live --persistent $mac_param
if egrep -q "eth|ens|em" <<< $bridge ; then
ip link set eth0 promisc on
cat << EOF > /tmp/direct-$guest.xml
<interface type='direct'>
  <source dev='$bridge' mode='bridge'/>
  <model type='virtio'/>
</interface>
EOF
virsh attach-device $guest /tmp/direct-$guest.xml
else
virsh attach-interface $guest --type $type --source $bridge --model $model --live --persistent $mac_param
fi
virsh domiflist $guest
}

check_parameters
mac_address
attach_nic
