#!/bin/bash
#This script add a kcli plan file sample "x.yml" by default or the first parameter as file name
parameters=$#
machine_name="machine"
if [ "$parameters" = 0 ] ; then file_path="x.yml"; else file_path=$1 ; fi
rm -i ${file_path} 
cat << EOF > "$file_path"
lab-net-test:
 type: network
 cidr: 192.168.222.0/24
xs-test:
  type: profile
  template: CentOS-7-x86_64-GenericCloud.qcow2
  memory: 256
  numcpus: 1
  disks:
   - size: 8
  nets:
   - lab-net-test
EOF
for ((x=1;x<4;x=x+1)) ; do
cat << EOF >> $file_path
$machine_name$x:
  profile: xs-test
EOF
done
echo "# Here is the content of the $file_path file : "
echo 
cat $file_path
