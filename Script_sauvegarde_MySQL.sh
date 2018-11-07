#!/bin/bash
# Script de sauvegarde des bases de données MySQL.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD
# Prérequis :
# Créer un utilisateur MySQL avec des privilèges minimaux dédié aux sauvegardes.
# Création de l’utilisateur avec son mot de passe.
# create user 'backupsql'@'localhost' identified by 'backuppassword'; 
# Attribution des droits à cet utilisateur.
# GRANT SELECT, RELOAD, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backupsql'@'localhost'; 

date=`date +"%d%m%Y-%H:%M:%S"`
emplacement='/home/sauvegardes'
export_erreur='/home/sauvegardes/erreur'
utilisateur=backupsql
motdepasse=backuppassword
base='mabase'
export="export_mabase"
log='/home/sauvegardes/logs'
log_erreur=/home/sauvegardes/erreur/erreur_export_"$(date +"%d%m%Y-%H:%M:%S")".log
rotation=8

# On teste la présence de l'emplacement de sauvegarde et du répertoire de logs
# Si ceux-ci n'existent pas, il seront crées
test_presence()
{
if [ ! -d $export_erreur ]
then
mkdir -p $export_erreur
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
echo "Début de l'export de la base $base le $(date +"%d %B %Y à %H:%M:%S")" >> $log/$export-$date.log
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
}

# On réalise l'export
dump()
{
mysqldump --user=$utilisateur --password=$motdepasse --log-error=$log_erreur $base > $emplacement/$export-$date.sql

# Si il n'y a aucune erreur, on affiche dans le mail le nom de l'export avec sa taille.
if [ "$?" -eq 0 ]
then
ls -lrth $emplacement |awk '{print $NF" "$5}' | tail -1 >> $log/$export-$date.log >> $log/$export-$date.log
echo "" >> $log/$export-$date.log

# On récupère l'état de l'export dans le dump
cat $emplacement/$export-$date.sql | tail -1 | tr "-" " " >> $log/$export-$date.log
else

# Si il y a des erreurs, alors le contenu du fichier de log d'erreur sera affiché dans le mail

cat $log_erreur >> $log/$export-$date.log

# On déplace l'export en erreur dans le dossier spécifique et on le renomme
mv $emplacement/$export-$date.sql $export_erreur/$export-$date.erreur
fi
}

# On écrit les derniers éléments dans le fichier de log
fin()
{
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
echo "Fin de l'export le $(date +"%d %B %Y à %H:%M:%S")" >> $log/$export-$date.log
echo "----------------------------------------------------------------------------------------------------" >> $log/$export-$date.log
}

# Dès que le nombre d'export est égal a 8, on supprime le plus ancien pour n’en garder que 7.
suppression()
{
nombre_export=$(ls -1 /home/mickael/sauvegardes/*.sql | wc -l)
ancien=$(ls -1 /home/mickael/sauvegardes/*.sql | head -1)
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
cat "$log/$export-$date.log" | mail -s "Export base $base" -r "Sauvegardes<mail@mail.fr>" supermail@mail.net

# Comme les exports en erreur ont une taille nulle, nous pouvons les supprimer
rm -rf $export_erreur/*.erreur
