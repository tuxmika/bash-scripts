#!/bin/bash
# Tester la disponibilité de vos hôtes avec un script.
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
hotes="xx.xx.xx.xx yy.yy.yy.yy zz.zz.zz.zz"
compteur=3 

for ip in $hotes

  do
  
recus=$(ping -c $compteur $ip | grep 'received' | awk -F',' '{ print $2 }' | awk '{print $1 }') > /dev/null

   case $recus in
0)echo -e " \033[1;31m`date +%d-%m-%Y-%T` Hôte: $ip : $compteur paquets transmis, $recus paquets reçus\033[0m";;
3)echo -e " \033[1;32m`date +%d-%m-%Y-%T` Hôte: $ip : $compteur paquets transmis, $recus paquets reçus\033[0m";;
   esac
   
done
