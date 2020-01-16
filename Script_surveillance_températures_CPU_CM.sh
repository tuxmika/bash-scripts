#!/bin/bash
# Script surveillance températures CPU et carte mère
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Pré-requis : lm-sensors

# Variables
warningcpu=20
criticalcpu=29
warningmb=20
criticalmb=29
sujetcpu="srvdebian : Alerte température CPU"
sujetmb="srvdebian : Alerte température MB"
mail=mail@mail.fr

temp1=$(sensors | grep "CPU Temperature" | tr '+' ' ' | tr '.' ' ' | awk '{print $3}')

    if [[ $temp1 -ge $warningcpu && $temp1 -lt $criticalcpu ]] ; then

echo "Warning : La température CPU est à $temp1°C" | mail -s " $sujetcpu" $mail

     elif [ $temp1 -ge $criticalcpu ] ; then

echo "Critical : La température CPU est à $temp1°C" | mail -s " $sujetcpu" $mail

fi

temp2=$(sensors | grep "MB Temperature" | tr '+' ' ' | tr '.' ' ' | awk '{print $3}')

        if [[ $temp2 -ge $warningmb && $temp2 -lt $criticalmb ]] ; then

echo "Warning : La température MB est à $temp2°C" | mail -s " $sujetmb" $mail

       elif [ $temp1 -ge $criticalmb ] ; then

echo "Critical : La température MB est à $temp2°C" | mail -s " $sujetmb" $mail

fi
