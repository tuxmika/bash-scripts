#!/bin/bash
# Script sauvegarde complète/incrémentale via tar
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
snapshot="/home/utilisateur/sauvegardes"
date=`date +%d-%B-%Y`
jour=`date +%A`
numero=`date +%U`
source="chemin du dossier à sauvegarder"
dossier="dossier à sauvegarder"
local="chemin de la sauvegarde locale"
retention=`date +%U --date='12 day ago'`
distant="chemin de la sauvegarde distante"
log="emplacement des logs"
ip="adresse ip"
user="utilisateur"

# Si le répertoire local n'existe pas, il sera crée.

if [ ! -d $local ];then

mkdir $local

   fi

echo "Début de la sauvegarde le $date à `date +%HH%M`" > $log

# Si nous sommes dimanche, alors on supprime le snapshot pour avoir une sauvegarde complète.

if [ $jour = dimanche ];then

rm $snapshot

echo "Nous sommes dimanche,le snapshot a été supprimé et la sauvegarde sera complète" >> $log

# On supprime sur le serveur SSH le dossier concerné par la rétention et on crée le nouveau.

ssh $user@$ip rm -rf $distant/sauvegarde_semaine_$retention
ssh $user@$ip mkdir $distant/sauvegarde_semaine_$numero

echo "Création du répertoire de la semaine $numero OK" >> $log

   fi

# On se place sur le chemin du dossier a sauvegarder.

cd $source

# On compresse au format tar.gz le dossier à sauvegarder.
# --listed-incremental=$snapshot : fichier snapshot qui servira à déterminer si la sauvegarde sera complète ou incrémentale

tar -zcf $local/sauvegarde.$date.tar.gz --listed-incremental=$snapshot $dossier

echo "Compression locale terminée" >> $log

# On envoie le dossier compressé sur le serveur

scp $local/sauvegarde.$date.tar.gz utilisateur@ip:$distant/sauvegarde_semaine_$numero

echo "Envoi de la sauvegarde locale vers le serveur terminé" >> $log

# On supprime la sauvegarde locale

rm -rf $local/sauvegarde.$date.tar.gz

echo "Suppression de la sauvegarde locale OK" >> $log

echo "Fin de la sauvegarde le $date à `date +%HH%M`" >> $log







