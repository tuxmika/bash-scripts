#!/bin/bash
# Script sauvegarde curlftpfs et rsync 
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : fichier .netrc ( https://ec.haxx.se/usingcurl/usingcurl-netrc )

jour=`date +%d-%m-%Y`
point_montage="/media/user/backup/ftp"
local="/media/user/backup/"
logs=/media/user/backup/logs
log=/media/user/backup/logs/sauvegarde_dossier_`date +%d-%m-%Y`
rotation=11
ftp="ftp.user.fr"

# Si le repertoire de logs et le point de montage n'existent pas, ils sont créés.

test -d $logs || mkdir -p $logs

test -d $point_montage || mkdir -p $point_montage

# Tout sera écrit dans /media/user/backup/logs/sauvegarde_wiki_`date +%d-%m-%Y`

exec > $log 2>&1

echo "-------------------------------------------------------------" 
echo  "Sauvegarde de dossier du $jour" 
echo "-------------------------------------------------------------" 
echo "Début de la sauvegarde le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 
echo  "Montage du FTP distant"
echo "-------------------------------------------------------------"

curlftpfs $ftp $point_montage && echo Montage terminé

echo "-------------------------------------------------------------" 
echo  "Sauvegarde Rsync"
echo "-------------------------------------------------------------"

# On copie tout le contenu de la source dans le dossier de destination.

rsync -az --stats $point_montage/dossier/ $local/dossier_`date +%d-%m-%Y`

# Si des erreurs, alors on effectue le démontage, on envoie le mail et on quitte le script.

if [ "$?" -ne 0 ]

then

umount -l $point_montage && echo Démontage terminé

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr

exit 1

fi

echo "-------------------------------------------------------------" 
echo  "Sauvegarde rsync terminée le $(date +%d-%m-%Y) à `date +%T`"
echo "-------------------------------------------------------------" 
echo  "Démontage du FTP distant"
echo "-------------------------------------------------------------"

umount -l $point_montage && echo Démontage terminé

echo "-------------------------------------------------------------" 
echo  "Compression de la sauvegarde"
echo "-------------------------------------------------------------"

cd $local

tar -czf dossier_`date +%d-%m-%Y`.tar.gz dossier_`date +%d-%m-%Y`

# Si des erreurs, alors on effectue le démontage, on envoie le mail et on quitte le script.

if [ "$?" -ne 0 ]

then

umount -l $point_montage && echo Démontage terminé

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr

exit 1

fi

echo  "Compression terminée le $(date +%d-%m-%Y) à `date +%T`"
echo "-------------------------------------------------------------"
echo  "Liste des sauvegardes avant rotation" 
echo "-------------------------------------------------------------"  

ls -lrth *.tar.gz | awk {'print $6" "$7" "$9" "$5'} 

# Une fois que la 11ème sauvegarde et la compression sont terminés, on effectue la rotation. 

nombre_sauvegardes=$(ls -1 *.tar.gz | wc -l)

ancien=$(ls -1rt *.tar.gz | head -1)

if [ $nombre_sauvegardes -eq $rotation ]

then

rm -rf $ancien

fi

echo "-------------------------------------------------------------" 
echo  "Liste des sauvegardes après rotation" 
echo "-------------------------------------------------------------" 

ls -lrth *.tar.gz | awk {'print $6" "$7" "$9" "$5'} 

# Si la compression et la rotation sont OK, alors on peut supprimer le dossier.

rm -rf dossier_`date +%d-%m-%Y`

echo "-------------------------------------------------------------"
echo "Fin de la sauvegarde le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr
