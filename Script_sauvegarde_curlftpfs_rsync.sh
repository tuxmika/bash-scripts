#!/bin/bash
# Script sauvegarde curlftpfs et rsync 
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : fichier .netrc ( https://ec.haxx.se/usingcurl/usingcurl-netrc )

jour=`date +%d-%B-%Y`
point_montage="/home/user/ftp"
local="/home/user/sauvegardes"
distant="dossier.domaine.fr"
logs="/home/user/sauvegardes/logs"
log="/home/user/sauvegardes/logs/sauvegarde_`date +%d-%m-%Y`"
rotation=4
ftp="ftp.domaine.fr"

test -d $logs || mkdir -p $logs

test -d $point_montage || mkdir -p $point_montage

# Tout sera écrit dans /home/user/sauvegardes/logs/sauvegarde_`date +%d-%m-%Y`"

exec > $log 2>&1

echo "-------------------------------------------------------------" 
echo  "Sauvegarde de $distant du $jour" 
echo "-------------------------------------------------------------" 
echo "Début de la sauvegarde le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 
echo  "Montage du FTP distant"
echo "-------------------------------------------------------------"

curlftpfs $ftp $point_montage && echo montage terminé

echo "-------------------------------------------------------------" 
echo  "Sauvegarde Rsync"
echo "-------------------------------------------------------------"

rsync -az --stats $point_montage/$distant $local/$distant-`date +%d-%B-%Y`

echo "-------------------------------------------------------------" 
echo  "Démontage du FTP distant"
echo "-------------------------------------------------------------"

umount -lv $point_montage

echo "-------------------------------------------------------------" 
echo  "Compression de la sauvegarde"
echo "-------------------------------------------------------------"

cd $local

tar -czf $distant-`date +%d-%B-%Y`.tar.gz $distant-`date +%d-%B-%Y` && echo compression terminée 

echo "-------------------------------------------------------------"
echo  "Liste des sauvegardes avant rotation" 
echo "-------------------------------------------------------------"  

ls -lrth *.tar.gz | awk {'print $6" "$7" "$9" "$5'} 

# Une fois que la 4ème sauvegarde et la compression sont terminés, on effectue la rotation. 

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

rm -rf $distant-`date +%d-%B-%Y`

echo "-------------------------------------------------------------"
echo "Fin de la sauvegarde le $(date +%d-%m-%Y) à `date +%T`" 
echo "-------------------------------------------------------------" 

cat $log | s-nail -s "Sauvegarde de $distant du $jour" user@mail.fr
