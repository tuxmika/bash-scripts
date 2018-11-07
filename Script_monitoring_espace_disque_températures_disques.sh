#!/bin/bash
#Script monitoring espace disque et températures disques
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD
# Pré-requis : hddtemp

# Variables
alerte=90
alerte2=60
liste="/dev/sda2 /dev/sdb1"
liste2="/dev/sda /dev/sdb"
mail=votre_adresse_mail

for disque in $liste
do
espace=$(df -h | grep $disque | awk {'print $5'} | sed 's/\%//g')
if [ $espace -ge $alerte ]; then
echo "`hostname` : Espace disque occupe a $espace% sur $disque" | mail -s "Espace
disque sur `hostname`" $mail
fi
done

for disque in $liste2
do
temp=$(/usr/sbin/hddtemp -n $disque)
if [ $temp -ge $alerte2 ]; then
echo "`hostname` : Temperature disque $disque a $temp degres" | mail -s
"Temperature disque sur `hostname`" $mail
fi
done
