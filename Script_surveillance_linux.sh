#!/bin/bash 
# Script de surveillance linux
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : traceroute, lm-sensors, htop, bmon, ncdu et speedtest ( https://github.com/sivel/speedtest-cli )

rougefonce='\e[0;31m' 
neutre='\e[0;m' 
clear 

echo "-------------------------------------------------------------------" 
echo -e "\033[20C SCRIPT DE SURVEILLANCE" 
echo "-------------------------------------------------------------------" 
echo "q: Quitter" 
echo "r: Retour" 
echo -e "\033[1m----------------------------SYSTEME--------------------------------\033[0m" 

echo "1: Visualiser les informations sur la machine" 
echo "2: Visualiser la date et l'heure" 
echo "3: Visualiser la mémoire disponible" 
echo "4: Visualiser l'espace disque" 
echo "5: Visualiser la taille des répertoires" 
echo "6: Vérifier le status des services" 
echo "7: Visualiser les températures/tensions/ventilateurs" 
echo "8: Visualiser le temps de fonctionnement du système" 
echo "9: Visualiser les utilisateurs connectés" 
echo "10: Visualiser les ressources et processus utilisées par le système" 
echo "11: Lister le matériel" 
echo "12: Visualiser les mises à jour disponibles" 

echo -e "\033[1m----------------------------RESEAU---------------------------------\033[0m" 

echo "13: Visualiser les interfaces réseaux" 
echo "14: Visualiser les connexions actives" 
echo "15: Effectuer un ping" 
echo "16: Visualiser son IP publique" 
echo "17: Effectuer un traceroute" 
echo "18: Effectuer une recherche DNS" 
echo "19: Surveiller la bande passante" 
echo "20: Effectuer un speedtest" 

until [ "$menu" = "q" ]; do 
echo -n "choix: " 
read menu 
if [ "$menu" = "q" ]; then 
echo "Au revoir" $exit 
fi 
if [ "$menu" = "r" ]; then 
exec $0 
fi 

  case $menu in 
  1 ) echo $(lsb_release -d) && echo Version du kernel: $(uname -r) && echo Hôte: $(hostname) && echo Adresse IP: $(hostname -I);; 
  2 ) date ;; 
  3 ) watch free -m;; 
  4 ) df -h ;; 
  5)  ncdu / ;; 
  6 )  echo -n "Entrer un nom de service : " 
      read nom 
     sudo service $nom status ;; 
  7 ) sensors;; 
  8 ) uptime ;; 
  9 ) who ;; 
  10) htop ;; 
  11) sudo lshw ;; 
  12) sudo apt-get update && /usr/lib/update-notifier/apt-check -p 
    echo \n;; 
  13 ) ifconfig -a ;; 
  14 ) netstat -a;; 
  15 ) echo -n "Entrer un nom ou une adresse IP : " 
     read adresse 
     echo -e "\e[0;31m Ctrl + c pour arrêter \033[0m" && ping $adresse;; 
  16) echo IP publique: $(wget -q http://checkip.dyndns.org -O- | cut -d: -f2 | cut -d\< -f1);; 
  17) echo -n "Entrer un nom ou une adresse IP : " 
      read adresse 
      traceroute $adresse;; 
  18) echo -n "Entrer un nom ou une adresse IP : " 
      read adresse 
      host -ta $adresse;; 
  19) bmon -p eth0;; 
  20) speedtest-cli;; 

esac 
done
