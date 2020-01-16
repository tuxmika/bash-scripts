#!/bin/bash
# Script surveillance memoire
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
mail="mail@admin.com"
sujet="Memoire libre <= 10% sur $HOSTNAME"

compteur=0

while true

do

# On attend 30 secondes entre chaque check

sleep 30

mem_libre=`free -mot | grep Mem: | awk {'print ($4+$6+$7)*100/$2'} | awk -F'.' {'print $1'}`

# Si la mémoire disponible est inférieure ou égale à 10 %

if [ $mem_libre -le 10 ]

 then

# On incrémente alors le compteur de 1

 compteur=$((compteur+1))

# Si le compteur arrive à 3

 if [ $compteur -ge 3 -a $mem_libre -le 10 ]

then

date=`date '+%d-%m-%Y %H:%M:%S'`   
top="$(ps -eo %mem,pid,comm | sort -nr | head -3)"

# Alors on envoie le mail d'alerte et on remet le compteur à 0

echo -e "$sujet\n\n" "$top" | mail -s "$date : $sujet" $mail

compteur=0

fi

else

# Si tout est ok, alors le compteur est à 0

compteur=0

fi

done
