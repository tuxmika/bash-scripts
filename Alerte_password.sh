#!/bin/bash
# Script notification changement mot de passe
# Licence MIT ( http://choosealicense.com/licenses/mit/ )

# Prérequis : Exim, heirloom-mailx

# Variables
liste="user1 user2"
mail="mail@admin.fr"
expediteur="Changement_mot_de_passe@admin.fr"

for user in $liste

do

timestamp_secondes=`grep $user /etc/shadow | awk -F ":" '{print $3*86400}'`

dernier_changement_secondes=$(date -d @$timestamp_secondes +%s)

dernier_changement_date=$(date -d @$timestamp_secondes +"%d %B %Y")

date_secondes=$(date +%s)

difference_secondes=$((date_secondes - dernier_changement_secondes))

difference_jours=$((difference_secondes / 86400))

if [[ $difference_jours -ge 60 ]];then

sujet="Changement mot de passe utilisatateur $user sur $HOSTNAME"

corps=" Le dernier changement du mot de passe de l'utilisateur $user sur $HOSTNAME a ete effectue le $dernier_changement_date ( $difference_jours jours )\n
 N'oubliez pas que la securite passe avant tout par un bon mot de passe"

echo -e "$corps" | mail -s "$sujet" -r $expediteur $mail

fi

done
