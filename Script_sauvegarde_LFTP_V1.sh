#!/bin/bash 
# Script de sauvegarde LFTP et du FTP sur SSL/TLS distant > local
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Pré-requis : lftp ( http://lftp.yar.ru )

userftp=user
passftp=password
hostftp=00.11.22.33
jour=$(date +%d-%m-%Y)
heure=$(date +%H:%M:%S)
logs=/home/user/sauvegardes/logs
log_ok=/home/user/sauvegardes/logs/sauvegarde_`date +%d-%m-%Y`
log_ko=/home/user/sauvegardes/logs/sauvegarde_ko_`date +%d-%m-%Y`
local="/home/user/sauvegardes"
distant="wiki.user.fr"
rotation=4 

# Si le dossier des logs n'existe pas, nous allons le créer.

test -d $logs || mkdir -p $logs

# Tout ce qui est OK sera écrit dans log_ok et tout ce qui est KO sera écrit dans log_ko.

exec 1>$log_ok
exec 2>$log_ko


echo "-------------------------------------------------------------" 
echo  "Sauvegarde de $distant du $(date +%d-%m-%Y)" 
echo "-------------------------------------------------------------" 
echo  "Début de la sauvegarde à `date +%T`" 
echo "-------------------------------------------------------------" 

# manuel lftp : https://lftp.yar.ru/lftp-man.html
# userftp, passftp, hostftp : identifiants FTP.
# -e de lftp avec des arguments entre guillemets : spécifie la commande ou les commandes à éxécuter
# mirror : Commande permettant d'effectuer une synchronisation entre un répertoire local et un répertoire distant.
# ftp:ssl-force true : On négocie une connexion SSL avec le serveur FTP.
# ftp:ssl-protect-data true : On demande une connexion SSL pour les transferts de données.
# ftp:ssl:verify-certificate no :  On désactive la vérification des certificats.
# distant : Votre dossier distant.
# local : Votre chemin local.
# quit : coupe la connexion après le transfert.

# On lance la sauvegarde et la compression

lftp "ftp://${userftp}:${passftp}@${hostftp}" -e "set ftp:ssl-force true; set ftp:ssl-protect-data true; set ssl:verify-certificate no; mirror $distant $local/sauvegarde_$jour; quit" 

# Si la dernière commande s'est mal déroulée, on envoie un mail et on quitte le script.

if [ "$?" -ne 0 ]

then

cat $log_ko | mutt -s "Erreur sur la sauvegarde de $distant du $jour" mail@mail.fr

exit 1

fi

# On se place dans le répertoire local et on compresse le dossier.

cd $local

tar -czvf sauvegarde_$jour.tar.gz sauvegarde_$jour 

# Si la dernière commande s'est mal déroulée, on envoie un mail et on quitte le script.

if [ "$?" -ne 0 ]

then

cat $log_ko | mutt -s "Erreur sur la compression de $distant du $jour" mail@mail.fr 

exit 1

fi

echo "-------------------------------------------------------------"
echo  "Liste des sauvegardes avant rotation" 
echo "-------------------------------------------------------------"  

ls -lrth *.tar.gz | awk {'print $6" "$7" "$9" "$5'} 

Une fois que la 4ème sauvegarde et la compression sont terminés, on effectue la rotation. 

nombre_sauvegardes=$(ls -1 $local/*.tar.gz | wc -l)

ancien=$(ls -1rt $local/*.tar.gz | head -1)

if [ $nombre_sauvegardes -eq $rotation ]

then

rm -rf $ancien

fi

echo "-------------------------------------------------------------" 
echo  "Liste des sauvegardes après rotation" 
echo "-------------------------------------------------------------" 

ls -lrth *.tar.gz | awk {'print $6" "$7" "$9" "$5'} 

# Si la compression et la rotation sont OK, alors on peut supprimer le dossier.

rm -rf sauvegarde_$jour

echo "-------------------------------------------------------------" 
echo "Fin de la sauvegarde de $distant le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 

# On envoie un mail récapitulatif

cat $log_ok | mutt -s "Sauvegarde de $distant du $jour" mail@mail.fr


