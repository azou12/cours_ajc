
#Mettre à jour le paquet
sudo apt-get update

#Installation des pacquets poiur permettre la commande apt d'utiliser un repository sur HTTPS
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

#Ajout de la clé officiel GPG de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Vérification que l'on a la clé avec l'emprunte digitale en recherchant les 8 premiers caractères
sudo apt-key fingerprint 0EBFCD88

#Configuration le repository stable
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
#Mise à jour du paquet
sudo apt-get update

#Installation de la dernière version de docker CE

sudo apt-get install -y docker-ce

#Vérification que Docker CE est correctement installé

sudo docker run hello-world

