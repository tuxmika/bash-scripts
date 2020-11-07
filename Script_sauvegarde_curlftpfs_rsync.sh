#!/bin/bash
# Script sauvegarde curlftpfs et rsync 
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : fichier .netrc ( https://ec.haxx.se/usingcurl/usingcurl-netrc )

jour=`date +%d-%B-%Y`
point_montage="/media/user/backup/ftp"
local="/media/user/backup/"
logs=/media/user/backup/logs
log=/media/user/backup/logs/sauvegarde_wiki_`date +%d-%m-%Y`
rotation=11
ftp="ftp.user.fr"

# Si le répertoire de logs et point de montage n'existent pas, ils seront crées

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

rsync -azXXX --stats $point_montage/dossier/ $local/dossier_`date +%d-%B-%Y`

# Si des erreurs lors de la sauvegarde

if [ "$?" -ne 0 ]

then

umount -lv $point_montage

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr

exit 1

fi

echo "-------------------------------------------------------------" 
echo  "Démontage du FTP distant"
echo "-------------------------------------------------------------"

umount -lv $point_montage

echo "-------------------------------------------------------------" 
echo  "Compression de la sauvegarde"
echo "-------------------------------------------------------------"

cd $local

tar -czf dossier_`date +%d-%B-%Y`.tar.gz dossier_`date +%d-%B-%Y` && echo Compression terminée 

# Si des erreurs lors de la compression

if [ "$?" -ne 0 ]

then

umount -lv $point_montage

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr

exit 1

fi

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

rm -rf dossier_`date +%d-%B-%Y`

echo "-------------------------------------------------------------"
echo "Fin de la sauvegarde le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 

cat $log | s-nail -s "Sauvegarde de dossier du $jour" mail@mail.fr
