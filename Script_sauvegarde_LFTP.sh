#!/bin/bash
# Script de sauvegarde complète/incrémentale avec LFTP
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD
# Pré-requis : lftp, MTA (Exim, Postfix, sSMTP...)

# Variables
userftp=identifiant
passftp=mot_de_passe
hostftp=ip_serveur
log=/home/user/sauvegardes
jour=$(date +%d-%B-%Y)
heure=$(date +%H:%M:%S)
local1="/home/user/dossier1" 
local2="/home/user/dossier2" 
distant=:/home/user/sauvegardes/ # ne pas oublier le slash à la fin du nom du répertoire distant
mail="mail@admin.com"

# manuel lftp : http://lftp.yar.ru/lftp-man.html
# userftp, passftp, hostftp : identifiants FTP.
# -e de lftp avec des arguments entre guillemets : spécifie la commande ou les commandes à éxécuter
# verbose : définit le niveau de verbosité.
# mirror : Commande permettant d'effectuer une synchronisation entre un répertoire local et un répertoire distant.
# -R de mirror : Permet la copie depuis l’emplacement local vers l’emplacement distant ( sans cette option, la copie s'effectue dans le sens distant > local ).
# -e de mirror : Spécifie qu'il faut supprimer les fichiers distants s'ils n'existent plus dans l’emplacement local.
# local : Votre chemin local.
# distant : Votre chemin distant ( si un slash est ajouté à la fin du nom du répertoire distant, alors votre répertoire local sera créé à l'intérieur du répertoire cible sur le serveur).

# Si le répertoire contenant les logs n'existe pas, celui-ci sera crée.

if [ ! -d $log ];then

mkdir $log

fi

# On teste avant tout si le serveur est accessible
# Si celui-ci est inacessible, on l'inscrit dans le fichier de log, on envoie un mail et on quitte le script.

recus=$(ping -c $compteur $hostftp | grep 'received' | awk -F',' '{ print $2 }' | awk '{print $1 }') > /dev/null

if [ $recus -eq 0 ];then

echo -e "$jour-$heure : Serveur inaccessible.\n$hostftp : $compteur paquets transmis, $recus paquets reçus\n\nAucune sauvegarde effectuée." > $log/sauvegarde_$jour

cat $log/sauvegarde_$jour | mail -s "Sauvegarde $jour" $mail

exit

fi

# Si tout est OK, lancement de la sauvegarde.

echo "Heure de demarrage de la sauvegarde : $(date +%H:%M:%S)" > $log/sauvegarde_$jour

echo "" >> $log/sauvegarde_$jour

echo "Sauvegarde de $local1" >> $log/sauvegarde_$jour

echo "" >> $log/sauvegarde_$jour

lftp "ftp://${userftp}:${passftp}@${hostftp}" -e "mirror --verbose=3  -R -e ${local1} ${distant} ; quit" >> $log/sauvegarde_$jour

echo "" >> $log/sauvegarde_$jour

echo "Sauvegarde de $local2" >> $log/sauvegarde_$jour

echo "" >> $log/sauvegarde_$jour

lftp "ftp://${userftp}:${passftp}@${hostftp}" -e "mirror --verbose=3  -R -e ${local2} ${distant} ; quit" >> $log/sauvegarde_$jour

echo "" >> $log/sauvegarde_$jour

echo "Heure de fin de la sauvegarde : $(date +%H:%M:%S)" >> $log/sauvegarde_$jour

# Pour finir, on envoie un mail récapitulatif.

cat $log/sauvegarde_$jour | mail -s "Sauvegarde $jour" $mail
