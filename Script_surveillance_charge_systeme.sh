#!/bin/bash
# Script de surveillance de la charge système
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
mail="mail@admin.com"
sujet="Charge CPU > 90% sur $HOSTNAME"

compteur=0

while true

do

# On attend 30 secondes entre chaque check

sleep 30

cpu_cores=`cat /proc/cpuinfo | grep 'processor' | wc -l`
load_1min=`cat /proc/loadavg | awk '{print $1}'`
charge=`echo $(($(echo $load_1min | awk '{print 100 * $1}') / $cpu_cores))`

# si la charge est supérieure ou égale à 90 %

if [ $charge -ge 90 ]

 then

# On incrémente alors le compteur de 1

     compteur=$((compteur+1))

# Si le compteur arrive à 3

   if [ $compteur -eq  3 ]

then

top="$(ps -eo %cpu,pid,comm | sort -nr | head -3)"

date=`date '+%d-%m-%Y %H:%M:%S'`   

# Alors on envoie le mail d'alerte et on remet le compteur à 0

    echo -e "$sujet\n\n" "$top" | mail -s "$date : $sujet" $mail

compteur=0

fi

else

# Si la charge n'est pas supérieure ou égale à 90 % alors le compteur est à 0

compteur=0

fi

done
