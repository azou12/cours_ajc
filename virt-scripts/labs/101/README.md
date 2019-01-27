# Lab 101

## Topologie

![lab101](https://www.lucidchart.com/publicSegments/view/cddee598-583c-41a4-8523-d17129144dfd/image.png)

## Description

Deux facilités réseaux :

* Un commutateur (switch) isolé qui fait office de réseau local appelé `lan101`
* Un routeur NAT/IPv6 qui fait office d'Internet appelé `wan101`

Deux machines :

* Un client connecté au switch `lan101` (eth0)
* Un routeur connecté au switch `lan101` (eth0) et au switch `wan101` (eth1) qui rendra les services DNS, DHCP, DHCPv6, SLAAC sur lan101. Les plages du LAN sont adressées en 192.168.168.0/24 et fd00:168:168::/64.

## Usage

Déploiement de la topologie.

```
cd ~/virt-scripts
labs/101/start.sh
```

Entrer dans le routeur virtuel.

```
virsh console r101
```

Lancer le script de configuration.

```
wget https://raw.githubusercontent.com/goffinet/virt-scripts/master/labs/101/router-firewall.sh
vim router-firewall.sh
bash -x router-firewall.sh
```

Sortir de `r101`

Entrer dans `pc1-101` et y réaliser le diagnostic TCP/IP

Note : on peut déployer automatiquement ce script dans la machine virtuelle.

```
cd ~/virt-scripts
labs/101/deploy.sh
```

Source du lab101 : https://github.com/goffinet/virt-scripts/blob/master/labs/101/

