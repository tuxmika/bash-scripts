#!/bin/bash
# Tester la disponibilité de vos hôtes avec un script
# le script va pinger votre réseau afin de déterminer les hôtes disponibles dans celu-ci.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD

# Variables
compteur=3 

for ip in $(seq 1 254)

  do
  
recus=$(ping -c $compteur 192.168.1.$ip | grep 'received' | awk -F',' '{ print $2 }' | awk '{print $1 }') > /dev/null

    case $recus in
0)echo -e " \033[1;31m`date +%d-%m-%Y-%T` Hôte: 192.168.1.$ip : $compteur paquets transmis, $recus paquets reçus\033[0m";;
3)echo -e " \033[1;32m`date +%d-%m-%Y-%T` Hôte: 192.168.1.$ip : $compteur paquets transmis, $recus paquets reçus\033[0m";;
esac

   done
