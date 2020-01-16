
#!/bin/bash 
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Script pour afficher les statistiques des dossiers ( liste, nombre, taille totale, taille par dossier...).
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
log='/var/log/liste.log' 
sujet='Liste des repertoires dans /home' 
emplacement='/home' 

cd $emplacement 
nombre=$(ls -d * | wc -l) 
taille_totale=$( du -ch * | awk 'END {print $1}') 
echo " Liste des repertoires situés dans /home (classement par taille):" > $log 
echo "" >> $log 
echo "nombre de repertoires : $nombre" >> $log 
echo "taille totale : $taille_totale" >> $log 
echo "" >> $log 
du -sB M * | sort -nr >> $log 
cat $log | mail -s "$sujet" -r mail@mail.fr
