#!/bin/bash
# Script de sauvegarde avec tar/gzip et chiffrement GPG.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : http://arobaseinformatique.eklablog.com/chiffrement-dechiffrement-asymetrique-avec-gnupg-a114562000
# Prérequis : http://arobaseinformatique.eklablog.com/creation-d-un-serveur-ssh-avec-authentification-par-cles-a3736670

date=`date +%d-%B-%Y`
#jour=`date +%A`
numero=`date +%U`
source="/home/utilisateur"
dossier="Documents"
local="/home/utilisateur/temp_backup"
retention=$(date +%U --date='5 week ago')
distant="/home/utilisateur/sauvegardes/sauvegarde_semaine_$numero/"
log="/home/mickael/Bureau/logs_sauvegardes"
hostssh="xx.xx.xx.xx"
userssh="utilisateur"
identifiant="identifiant_clé_GPG"

nom()
{
echo "-------------------------------------------------------------" > $log/sauvegarde_semaine_$numero.log
echo -e "Sauvegarde de $source/$dossier du $(date +%d-%B-%Y)" >> $log/sauvegarde_semaine_$numero.log
echo "-------------------------------------------------------------" >> $log/sauvegarde_semaine_$numero.log
}
# Si le répertoire local n'existe pas, il sera crée.

if [ ! -d $local ];then

mkdir $local

fi

# Si le répertoire des logs n'existe pas, il sera crée.

if [ ! -d $log ];then

mkdir $log

fi

nom

echo "Début de la sauvegarde le $date à `date +%T`" >> $log/sauvegarde_semaine_$numero.log

echo "" >> $log/sauvegarde_semaine_$numero.log

# On se place sur le chemin du dossier a sauvegarder.

cd $source

# On compresse au format tar.gz et on chiffre le dossier à sauvegarder.
# tar czf : on crée une archive tar.gz du dossier
# Le pipe | : va permettre de rediriger la sortie de la 1ère commande vers la seconde.
# -e : indique qu'il faut chiffrer
# -r : spécifie l'identifiant de la clé avec lequel le fichier doit être chiffré ( 8 caractères )
#-o [dossier sorti] : définit le nom du fichier à la sortie.

tar czf - $dossier | gpg -e -r $identifiant -o $local/sauvegarde_semaine_$numero.tar.gz.gpg

# Statut de la compression

status=$?
case $status in
0) echo "Compression terminée à `date +%T`" >> $log/sauvegarde_semaine_$numero.log ;;
1) echo "Une erreur s'est produite lors de la compression" >> $log/sauvegarde_semaine_$numero.log && exit;;
esac

echo "" >> $log/sauvegarde_semaine_$numero.log

# Transfert des fichiers

rsync -avz --stats --protect-args -e ssh $local/sauvegarde_semaine_$numero.tar.gz.gpg $userssh@$hostssh:$distant >> $log/sauvegarde_semaine_$numero.log

# -a : mode archivage ( équivalent -rlptgoD ).
# -z : compression des données pendant le transfert.
# -e : pour spécifier l’utilisation de ssh
# -- stats : donne des informations sur le transfert (nombre de fichiers...).
# --protect -args : Si vous avez besoin de transférer un nom de fichier qui contient des espaces , vous pouvez le spécifier avec cette option.

status=$?
echo "" >> $log/sauvegarde_semaine_$numero.log

# Codes de retour rsync

case $status in
0) echo Succès >> $log/sauvegarde_semaine_$numero.log;;
1) echo Erreur de syntaxe ou d'utilisation >> $log/sauvegarde_semaine_$numero.log;;
2) echo Incompatibilité de protocole >> $log/sauvegarde_semaine_$numero.log;;
3) echo Erreurs lors de la sélection des fichiers et des répertoires d'entrée/sortie >> $log/sauvegarde_semaine_$numero.log;;
4) echo Action non supportée : une tentative de manipulation de fichiers 64-bits sur une plate-forme qui ne les supporte pas \
 ; ou une option qui est supportée par le client mais pas par le serveur. >> $log/sauvegarde_semaine_$numero.log;;
5) echo Erreur lors du démarrage du protocole client-serveur >> $log/sauvegarde_semaine_$numero.log;;
6) echo Démon incapable d'écrire dans le fichier de log >> $log/sauvegarde_semaine_$numero.log;;
10) echo Erreur dans la socket E/S >> $log/sauvegarde_semaine_$numero.log;;
11) echo Erreur d'E/S fichier >> $log/sauvegarde_semaine_$numero.log;;
12) echo Erreur dans le flux de donnée du protocole rsync >> $log/sauvegarde_semaine_$numero.log;;
13) echo Erreur avec les diagnostics du programme >> $log/sauvegarde_semaine_$numero.log;;
14) echo Erreur dans le code IPC>> $log/sauvegarde_semaine_$numero.log;;
20) echo SIGUSR1 ou SIGINT reçu >> $log/sauvegarde_semaine_$numero.log;;
21) echo "Une erreur retournée par waitpid()" >> $log/sauvegarde_semaine_$numero.log;;
22) echo  Erreur lors de l'allocation des tampons de mémoire principaux >> $log/sauvegarde_semaine_$numero.log;;
23) echo Transfert partiel du à une erreur >> $log/sauvegarde_semaine_$numero.log;;
24) echo Transfert partiel du à la disparition d'un fichier source >> $log/sauvegarde_semaine_$numero.log;;
25) echo La limite --max-delete a été atteinte >> $log/sauvegarde_semaine_$numero.log;;
30) echo Dépassement du temps d'attente maximal lors d'envoi/réception de données >> $log/sauvegarde_semaine_$numero.log;;
35) echo Temps d’attente dépassé en attendant une connection >> $log/sauvegarde_semaine_$numero.log;;
255) echo Erreur inexpliquée >> $log/sauvegarde_semaine_$numero.log;;
esac

echo "" >> $log/sauvegarde_semaine_$numero.log

# On supprime la sauvegarde locale et on vérifie sa suppression.

rm -rf $local

# Statut de la suppression
status=$?

case $status in
0) echo "Suppression de la sauvegarde locale terminée à `date +%T`" >> $log/sauvegarde_semaine_$numero.log ;;
1) echo "Une erreur s'est produite lors de la suppression" >> $log/sauvegarde_semaine_$numero.log && exit;;
esac

# On supprime les anciennes sauvegardes distantes suivant la rétention.

ssh $userssh@$hostssh rm -rf "/home/utilisateur/sauvegardes/sauvegarde_semaine_$retention"


echo "" >> $log/sauvegarde_semaine_$numero.log
echo "-------------------------------------------------------------" >> $log/sauvegarde_semaine_$numero.log
echo "Fin de la sauvegarde le $date à `date +%T`" >> $log/sauvegarde_semaine_$numero.log
echo "-------------------------------------------------------------" >> $log/sauvegarde_semaine_$numero.log
