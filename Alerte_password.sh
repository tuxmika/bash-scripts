#!/bin/bash
# Script notification changement mot de passe
# Le script enverra un mail si le mot de passe n'a pas été changé depuis 85 jours ou plus.
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : Postfix , mutt

# Variables
liste="mickael"
destinataire="breizhmika@outlook.fr"

for user in $liste

do

# On cherche le nombre de jours écoulés entre le 1er janvier 1970 et le dernier changement du mot de passe et on le convertit en secondes.

timestamp_user=$(grep $user /etc/shadow | awk -F ":" '{print $3*86400}')

# On convertit le résultat en date sous la forme 'jour mois année'.

dernier_changement_date=$(date -d @$timestamp_user +"%d %B %Y")

# On convertit la date du jour en secondes.

date_secondes=$(date +%s)

# On calcule la différence entre la date du jour et celle du dernier changement.

difference_secondes=$((date_secondes - $timestamp_user))

# On convertit le résultat en jours.

difference_jours=$((difference_secondes / 86400))

# Si le résultat est égal ou supérieur à 85 jours et plus petit ou égal à 90, on envoie une notification.

if [ $difference_jours -ge 85 -a $difference_jours -le 90 ]

then

sujet="Changement mot de passe utilisateur $user sur $HOSTNAME"

corps="Le dernier changement du mot de passe de l'utilisateur $user sur $HOSTNAME a été effectué le $dernier_changement_date ( $difference_jours jours )"

echo -e "$corps" | mutt -s "$sujet" -e 'my_hdr From:Changement_mot_de_passe<changement_mot_de_passe@tux.local>' $destinataire

else

# Si le résultat est égal ou supérieur à 90 jours, on notifie le dépassement.

sujet="Changement mot de passe utilisateur $user sur $HOSTNAME"

corps="La date des 90 jours pour le changement du mot de passe de l'utilisateur $user sur $HOSTNAME a été dépassée ( $difference_jours jours )"

echo -e "$corps" | mutt -s "$sujet" -e 'my_hdr From:Changement_mot_de_passe<changement_mot_de_passe@tux.local>' $destinataire

fi

done

