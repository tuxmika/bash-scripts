#!/bin/bash
# Script analyse ClamAV
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD
# Le script effectuera via un tâche cron que vous aurez programmé une analyse complète tous les dimanches et une analyse journalière qui scannera uniquement les fichiers modifiés ou crées depuis les dernières 24 heures.

# Variables
log="/var/log/clamav/analyse_`date +%d-%m-%Y`.log"
sujet="Analyse CLAMAV du `date +%d-%m-%Y`"
expediteur="clamav@mail.fr"
destinataire="mail@mail.fr"
emplacement="/home"
date=`date +%d-%m-%Y`
heure=`date +%H:%M:%S`
quarantaine="/home/clamav_quarantaine"
jour=`date +%A`

updates() 
{ 
http://linux.die.net/man/1/freshclam

echo -e "***************************************************\n" > $log
echo -e "\tMises à jour ClamAV du $date\n" >> $log
echo -e "***************************************************\n" >> $log

freshclam --quiet

status=$?

case $status in

0)  echo La base de données est mise à jour >> $log;;
40) echo Option inconnue passée >> $log ;;
50) echo Vous ne pouvez pas changer de répertoire >> $log;;
51) echo Impossible de vérifier la somme MD5 >> $log;;
52) echo Problème de connexion '(réseau)' problème >> $log;;
53) echo Vous ne pouvez pas dissocier le fichier >> $log;;
54) echo MD5 ou erreur de vérification de signature numérique >> $log;;
55) echo Erreur de lecture du fichier >> $log;;
56) echo Erreur de fichier de configuration >> $log;;
57) echo Impossible de créer le nouveau dossier >> $log;;
58) echo Impossible de lire la base de données de serveur à distance >> $log;;
59) echo Les miroirs ne sont pas parfaitement synchronisées - réessayer plus tard >> $log;;
60) echo Vous ne pouvez pas obtenir des informations sur utilisateur à partir de /etc/passwd >> $log;;
61) echo Impossible de supprimer les privilèges >> $log;;
62) echo Impossible d'initialiser l'enregistreur >> $log;;

esac

if [ $status -ne 0 ];then

cat $log | mail -s "Problème de mise à jour ClamAV" -r $expediteur $destinataire

exit

fi

}

analyse()
{
echo -e "                                                   \n" >> $log
echo -e "***************************************************\n" >> $log
echo -e "\tAnalyse Clamav du $date\n" >> $log
echo -e "***************************************************\n" >> $log

if [ $jour = dimanche ];then

nice -n 15 clamscan -r $emplacement --infected --move=$quarantaine >> $log

cat $log | mail -s "Analyse ClamAV du $date" -r $expediteur $destinataire

else

nice -15 find $emplacement -mtime 1 -print0 | xargs -0 clamscan -r --infected --move=$quarantaine >> $log

cat $log | mail -s "Analyse ClamAV du $date" -r $expediteur $destinataire

fi

}

updates

analyse
