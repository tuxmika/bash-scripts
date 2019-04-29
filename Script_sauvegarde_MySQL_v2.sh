#!/bin/bash
# Script de sauvegarde des bases de données MySQL.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : mailx et postfix sur Centos et bsd-mailx et postfix sur Debian
# Créer un utilisateur MySQL avec des privilèges minimaux dédié aux sauvegardes.
# Création de l’utilisateur avec son mot de passe.
# create user 'backupsql'@'localhost' identified by 'backuppassword'; 
# Attribution des droits à cet utilisateur.
# GRANT SELECT, RELOAD, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backupsql'@'localhost'; 

date=`date +"%d%m%Y-%H:%M:%S"`
utilisateur=backupsql
motdepasse=backuppassword
base='ma_base'
export="export_ma_base"
repertoire_dump='/home/sauvegardes/dump'
log='/home/sauvegardes/logs'
log_erreur=/home/sauvegardes/logs/export-erreur-"$(date +"%d%m%Y-%H:%M:%S")".log
rotation=8
destinataire=mail@mail.fr

# On teste la présence du dossier "repertoire_dump" et du répertoire de logs.
# Si ceux-ci n'existent pas, il seront crées.
test_presence()

{
if [ ! -d $repertoire_dump ]

     then

mkdir -p $repertoire_dump

   fi

if [ ! -d $log ]

    then

mkdir -p $log

  fi

}

# On écrit les 1er éléments dans le fichier de log
debut()
{
echo "----------------------------------------------------------------------------------------------------" > $log/$export-$date.log
echo "Export de la base $base du $(date +"%d %B %Y à %H:%M:%S")" >> $log/$export-$date.log
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
}

# On réalise l'export
# http://man.he.net/man1/mysqldump

dump()
{

mysqldump --user=$utilisateur --password=$motdepasse --log-error=$log_erreur $base > $repertoire_dump/$export-$date.sql

# Si il n'y a aucune erreur, on affiche dans le mail le nom de l'export avec sa taille.

if [ "$?" -eq 0 ]

    then

ls -lrth $repertoire_dump |awk '{print $NF" "$5}' | tail -1 >> $log/$export-$date.log >> $log/$export-$date.log

echo "" >> $log/$export-$date.log

# On récupère l'état de l'export dans le dump

cat $repertoire_dump/$export-$date.sql | tail -1 | tr "-" " " >> $log/$export-$date.log

     else

# Si il y a des erreurs, alors le contenu du fichier de log d'erreur sera affiché dans le mail et on supprimera le log d'erreur

cat $log_erreur >> $log/$export-$date.log

    fi

}

# On écrit les derniers éléments dans le fichier de log

fin()
{
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
echo "Fin du traitement le $(date +"%d %B %Y à %H:%M:%S")" >> $log/$export-$date.log
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
}

# Dès que le nombre d'export est égal a 8, on supprime le plus ancien pour n’en garder que 7.

suppression()
{
nombre_export=$(ls -1 /home/sauvegardes/dump/*.sql | wc -l)

ancien=$(ls -1 /home/sauvegardes/dump/*.sql | head -1)

if [ $nombre_export -eq $rotation ]

    then

rm -rf $ancien

   fi
}

test_presence
debut
dump
fin
suppression

# On envoie le mail

cat "$log/$export-$date.log" | mail -s "Export base $base" -r "Sauvegardes<mail@mail.fr>" $destinataire

# Nous pouvons les supprimer les exports en erreur qui ont une taille à 0 et les logs d'erreur.
# On supprime également les logs qui ont plus de 15 jours.

find /home/sauvegardes/dump -iname '*.sql' -type f -size 0 -exec rm -rf {} \;

find /home/sauvegardes/logs -iname '*erreur*' -type f -exec rm -rf {} \;

find /home/sauvegardes/logs -type f -mtime +15 -exec rm -rf {} \;
