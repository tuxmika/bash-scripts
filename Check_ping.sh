#!/bin/bash
# Tester la disponibilité de vos hôtes avec un script
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD

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
