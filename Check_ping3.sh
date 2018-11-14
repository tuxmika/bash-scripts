#!/bin/bash
# Tester la disponibilité de vos hôtes avec un script
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD

# Variables
hotes="xxx.xxx.x.xx xxx.xxx.x.xx"
compteur=4
date=$(date +"%d %B %Y - %T")
mail=mail@admin.com

for ip in $hotes
   do
# % de paquets perdus
perte=$(ping -c $compteur $ip | grep -oP '\d+(?=% packet loss)') > /dev/null

# Si % égal à 100, alors alerte critique
if [ $perte -eq 100 ];then
touch /tmp/critical.$ip
sujet_critical="$date : PING CRITICAL sur $ip"
echo "PING CRITICAL sur $ip : paquets perdus $perte%" | mail -s "$sujet_critical" $mail
   else

# Si % ≥ 50 et < 100 alors alerte warning
if [ $perte -ge 50 -a $perte -lt 100 ];then
touch /tmp/warning.$ip
sujet_warning="$date : PING WARNING sur $ip"
echo "PING WARNING sur $ip : paquets perdus $perte%" | mail -s "$sujet_warning" $mail
    else

# Si la perte de perte de paquets revient à 0 après une alerte, une notification OK est envoyée
if [ -f /tmp/critical.$ip -o -f /tmp/warning.$ip ]
    then
rm /tmp/*.$ip
sujet_ok="$date : PING OK sur $ip"
echo "PING OK sur $ip : paquets perdus $perte%" | mail -s "$sujet_ok" $mail
     fi
  fi
 fi
done
