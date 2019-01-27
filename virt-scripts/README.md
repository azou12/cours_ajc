# Virt-scripts

This suite of "quick and dirty" scripts are intended to mount virtual sandboxes for labs during Linux training courses with KVM/libvirtd (on Centos 7 or Debian Jessie hosts).
The main goal is to spawn quickly linux guests for lab purposes. But we can find other subsequents objectives as coding/scripting, automation or virtual networks and system management, helping to understand virtual infrastructures technologies and architectures. Only for educational purposes.

Three groups of scripts :

1. Native installation for Centos 7 Debian 9 and Ubuntu 18.04 and post-installation.
2. Quickbuilder, guests spwaning with pre-builded images
3. Devices management

If you already have images at stock, there exists beter ways to automate and manage libvirt guest like those nice scripts :

* in python :  `kcli` (https://github.com/karmab/kcli/tree/master/kvirt)
* in bash : https://github.com/vpenso/libvirt-shell-functions

For native installation of Arch Linux : look at https://github.com/Anthony25/spawn-archlinux-libvirt.


## Native installation and post-installation

Purposes : gold image auto-creation

1. `autoprep.sh` : prepare your system as virtualization host
* `get-iso.sh` : get iso distributions for fresh installations
* `auto-install.sh` : build a fresh Centos, Debian or Ubuntu system with http repos and kickstart files
* `auto-install-tui.sh` : auto-install.sh text user interface demo
* `sparsify.sh` : optimize space disk on the designated guest
* `clone.sh` : clone, sysprep and optimize builded guests
* `hosts-file` : print the running guests and their ipv4 address
* `nested-physical.sh` : nested virtualization installation on the physical host

## Quickbuilder

Purposes : deploy quickly guests based on pre-builded with previous scripts. Some images are avaible on https://get.goffinet.org/kvm : centos7 centos7.5 debian7 debian8 ubuntu1604 ubuntu1804 kali metasploitable openwrt15.05.

1. `define-guest-image.sh` : deploy pre-builded images (like a quickbuilder, provisionner)
* `get_and_install_openwrt.sh` : get and start openwrt with two interfaces

But this is probably beter to build by yourself your appliance with the `auto-install.sh` script. The root account and the password are in the preseed and kickstart templates included.

## Devices management

Purposes : change RAM and vcpus, add block devices and network facilities

1. `add-memory.sh` : add RAM
* `add-vcpu.sh` : set vcpus count
* `add-bridge.sh` : add an isolated or ipv4 nat/ipv6 ula libvirt bridge
* `add-nic.sh` : a new NIC on live guest to a bridged interface
* `attach-nic.sh` : attach a live guest present NIC to a bridge
* `detach-nic.sh` : detach a live guest from a bridge
* `add-storage.sh` : attach an empty bit disk by GB size
* `start_all.sh` : start all the defined guests
* `destroy_and_undefine_all.sh` : destroy,  undefine all the guests with storage removing

## How-To

First clone this project in your home directory :

```
cd
git clone https://github.com/goffinet/virt-scripts
cd virt-scripts
```

### Step 1 : Verify your installation

Script : `autoprep.sh`

Description : Setup KVM/Libvirtd/LibguestFS on RHEL7/Centos 7/Debian Jessie.

Usage :

```
# ./autoprep.sh
This script will install all the necessary packages to use Libvirtd/KVM
Please reboot your host after this step
Are you sure? [y/N]
```

### Step 2 : Get iso images (optionnal, outdated)

Script : `get-iso.sh`

Description : Get latest iso of Centos 7, Debian Jessie and Ubuntu Xenial.

Usage :

```
# ./get-iso.sh
Usage : ./get-iso.sh [ centos | debian | ubuntu ]
```

### Step 3 : Build a guest automatically

Script : `auto-install.sh`

Description :  Centos 7, Debian Stretch or Ubuntu Bionic fully automatic installation by HTTP Repo and response file (preseed or kickstart) via local HTTP server.

Usage :

Please check all the parameters. For customization, you can adapt the kickstart or preseed templates inside the script.

```
# ./auto-install.sh
Centos 7, Debian Jessie or Ubuntu Xenial fully automatic installation by HTTP Repos and response file via local HTTP.
Usage : ./auto-install.sh [ centos | debian | ubuntu ] nom_de_vm
Please provide one distribution centos, debian, ubuntu and one guest name: exit
```

Note : Escape character is `^]` (CTRL+ `]`)


### Step 4 : Sparse your native image

Script : `sparsify.sh`

Description : Sparse a disk. Great gain on disk space !

Usage :

```
./sparsify.sh
This script sparses an attached disk
Please provide a the guest name of a destroyed guest: exit
Usage : ./sparsify.sh <guest name>
```

Check the disk usage : 2,0G

```
# du -h /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
2,0G    /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
```

Sparsify operation

```
# ./sparsify.sh ubuntu-gold-31122016

Sparse disk optimization
[   0,1] Create overlay file in /tmp to protect source disk
[   0,1] Examine source disk
[   4,3] Fill free space in /dev/sda1 with zero
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ --:--
[   6,9] Fill free space in /dev/u1-vg/root with zero
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ 00:00
[  70,6] Clearing Linux swap on /dev/u1-vg/swap_1
[  71,9] Copy to destination and make sparse
[ 191,4] Sparsify operation completed with no errors.
virt-sparsify: Before deleting the old disk, carefully check that the
target disk boots and works correctly.
```

Check the disk usage : 432M


```
# du -h /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
432M    /var/lib/libvirt/images/ubuntu-gold-31122016.qcow2
```

### Step 5 : Clone your guest

Script : clone.sh

Description : Cloning a domain disk with sparsifying and Linux sysprep.

Usage :

```
./clone.sh
This script clones, sparsifies and syspreps linux guest
Usage : './clone.sh <original guest> <destination guest>'
Please provide a the guest name of a destroyed guest: exit
```

### Step 6 : Quickbuilder

Assume that you have installed three guests with `auto-install.sh` :

```
~/virt-scripts# ./auto-install.sh centos7 centos
~/virt-scripts# ./auto-install.sh debian8 debian
~/virt-scripts# ./auto-install.sh ubuntu1604 ubuntu
```

And you can verify it :

```
~/virt-scripts# virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     centos7                        shut off
 -     debian8                        shut off
 -     ubuntu1604                     shut off

```

Move those images disk into the `virt-scripts` directory and undefine original guests :

```bash
#!/bin/bash
cd ~/virt-scripts
for x in centos7 debian8 ubuntu1604
do
mv /var/lib/libvirt/images/$x.qcow2 ./
virsh undefine $x
done

```

And you can deploy quicky builded and optimized guests based on those images :

```
~/virt-scripts# ./define-guest-image.sh c1 centos7

Début d'installation...
Création du domaine...                                                   |    0 B     00:00
Création du domaine terminée.  Vous pouvez redémarrer votre domaine en lançant :
  virsh --connect qemu:///system start c1
```

```
~/virt-scripts# ./define-guest-image.sh d1 debian8

Début d'installation...
Création du domaine...                                                   |    0 B     00:00
Création du domaine terminée.  Vous pouvez redémarrer votre domaine en lançant :
  virsh --connect qemu:///system start d1
```

```
~/virt-scripts# ./define-guest-image.sh u1 ubuntu1604

Début d'installation...
Création du domaine...                                                   |    0 B     00:00
Création du domaine terminée.  Vous pouvez redémarrer votre domaine en lançant :
  virsh --connect qemu:///system start u1
```

Also, I have prebuilded other images for training classes :

```
~/virt-scripts# ./define-guest-image.sh
Usage : ./define-guest-image.sh <name> <image>
Please download one of those images :
https://get.goffinet.org/kvm/debian7.qcow2
https://get.goffinet.org/kvm/debian8.qcow2
https://get.goffinet.org/kvm/centos7.qcow2
https://get.goffinet.org/kvm/ubuntu1604.qcow2
https://get.goffinet.org/kvm/metasploitable.qcow2
https://get.goffinet.org/kvm/kali.qcow2
https://get.goffinet.org/kvm/arch.qcow2
```

### Step 7 : Manage guests

Verify your running guests

```
~/virt-scripts# virsh list
 Id    Name                           State
----------------------------------------------------
 88    c1                             running
 89    d1                             running
 90    u1                             running
```

Access to the text console

```
~/virt-scripts# virsh console c1
Connected to domain c1
Escape character is ^]

CentOS Linux 7 (Core)
Kernel 3.10.0-514.6.2.el7.x86_64 on an x86_64

centos7 login:
```

To exit from the text console execute CTRL `]`.

### Step 8 : Add the guest hostname resolution

Script :

Description : Print a new `/etc/resolv.conf` with the ip address and the hostname of running guests.

Usage :

```
./hosts-file.sh
```

For example :

```
./hosts-file.sh
192.168.122.47 c1
192.168.122.56 d1
192.168.122.118 u1
```

To update your `/etc/hosts` :

```
./hosts-file.sh >> /etc/hosts
```

SSH is enabled by default :

```
~/virt-scripts# ssh c1
The authenticity of host 'c1 (192.168.122.47)' can't be established.
ECDSA key fingerprint is 04:be:d2:e9:d9:9a:98:02:e3:a8:34:2d:3a:dd:26:a5.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'c1,192.168.122.47' (ECDSA) to the list of known hosts.
root@c1's password:
[root@centos7 ~]# exit
déconnexion
Connection to c1 closed.
```

### Step 9 : Manage devices

Script : add-bridge.sh

Description : add an isolated or ipv4 nat/ipv6 ula libvirt bridge

Usage :

```
./add-bridge.sh
Description : This script create an isolated or a nat/ipv6 bridge
Usage       : ./add-bridge.sh <name> <interface> <type, isolated or nat>
Example     : './add-bridge.sh net1 virbr100 isolated' or './add-bridge.sh lan101 virbr101 nat'
```

Script : add-storage.sh

Description : attach an empty bit disk by GB size

Usage :

```
./add-storage.sh
Description : This script attach a disk to a live guest
Usage       : ./add-storage.sh <guest name> <block device name> <size in GB>
Example     : './add-storage.sh guest1 vdb 4' add a vdb 4GB disk to guest1
```

To be continued ...

### Next steps ...

* Integrate kcli for guests management
* Install ansible, add ssh hosts keys, create an ansible inventory and test your managed nodes.
* Exploit snapshots and virtual storage
* Exploit free-ipa, pacemaker, ovirt, openstack, gns3 (see kcli plans)

## Todo

* `auto-install.sh`
  * ~~Fedora~~
* `create_repo.sh` : create local repo
* Revise code and comment, comment, comment ...
# cours_ajc
