#!/bin/bash 
# Script de sauvegarde FTP
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Pré-requis : lftp ( http://lftp.yar.ru )

# Informations sur le serveur FTP 
hostname=srv
ftp_serveur=adresse_ip
username=user
password=password

# Repertoires à sauvegarder 
source="/home/user/Images" 
source2="/home/user/Documents" 

# Repertoire ou sera enregistré la sauvegarde locale 
destination="/home/user/`date +%d-%B-%Y `" 

# Format de la date 
date=`date +%d-%B-%Y` 

# http://manpagesfr.free.fr/man/man3/basename.3.html
nom=`basename $source` 
nom2=`basename $source2` 

# Emplacement des logs 
log="/home/user/FTP/Sauvegarde-FTP-$date" 

# Rétention / rotation des sauvegardes ( 7 jours ) 
retention=`date +%d-%B-%Y --date='7 day ago'` 

# Si le répertoire de sauvegarde local n'existe pas, il sera crée 
if [ ! -d $destination ] ;then 
mkdir $destination && cd $destination 
fi 

echo "Début de la sauvegarde le $date à `date +%HH%M` " > $log 

# Compression des dossiers en .tar,gz
echo "Compression des dossiers débutée à `date +%HH%M` " >> $log 
tar -czf $destination/$nom-$date.tar.gz -C $source/.. $nom 
tar -czf $destination/$nom2-$date.tar.gz -C $source2/.. $nom2 

# Statut de la compression 
status=$? 
case $status in 
0) echo "Compression des dossiers terminée à `date +%HH%M`" >> $log ;; 
1) echo "Une erreur s'est produite lors de la compression des dossiers" >> $log && exit;; 
esac

echo "Envoi des fichiers sur $hostname à `date +%HH%M`" >> $log 

# Envoi de la sauvegarde locale vers le serveur FTP 
lftp ftp://$username:$password@$ftp_serveur -e "mirror -e -R $destination /home/user/$date;quit"  >> $log

# Rotation des sauvegardes 
lftp ftp://$username:$password@$ftp_serveur -e "rm -rf $retention;quit" 

echo "Sauvegarde terminée le $date à `date +%HH%M`" >> $log 

# Suppression du répertoire de sauvegarde local 
rm -rf $destination

# Statut de la suppression
status=$? 
case $status in 
0) echo "Suppression du répertoire de sauvegarde local terminé à `date +%HH%M`" >> $log ;; 
1) echo "Une erreur s'est produite lors de la suppression" >> $log && exit;; 
esac
