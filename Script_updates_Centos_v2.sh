#!/bin/bash
# Script mises à jour Centos 
# Le script va lister le nombre et le nom des paquets qui seront mis à jour.
# Il va ensuite les installer et pour terminer envoyer un mail récapitulatif.
# Si un reboot est nécessaire suite à un upgrade de kernel , une notification sera inscrite en fin de mail.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )
# Prérequis : mutt

log=/home/utilisateur/.updates
destinataire=mail@mail.fr
sujet="Mises à jour disponibles sur $HOSTNAME"
jour=`date +%d-%m-%Y`
heure=`date +%H:%M:%S`
erreur=/home/utilisateur/.updates/erreur.log

> $erreur

if [ ! -d $log ];then

mkdir $log

fi

maj_centos()

{

echo -e "-------------------------------------------------------------------------------------------------" > $log/update_$jour-$heure

echo -e "\tMises à jour du $(date +%d" "%B" "%Y)" sur $HOSTNAME >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tEtape 1 : Liste des mises à jours disponibles" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

yum check-update > /dev/null

liste_centos=$(yum -q check-update | tail -n+2 | awk {'print $1'})
nombre_centos=$(yum -q check-update | tail -n+2 | wc -l)

if [ $nombre_centos -eq 0 ];then

rm -rf $log/update_$jour-$heure && exit

fi

for i in $liste_centos ;do

actuelle=$(yum list installed $i | awk {'print $1,$2'} | tail -n+2) 

maj=$(yum -q check-update | tail -n+2 | awk {'print $1,$2'} | grep -w $i) 

echo "" >> $log/update_$jour-$heure 
   
echo -e "$i :\nInstallé : $actuelle\nCandidat : $maj\n" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

done

echo -e "\tNombre total de mises à jour disponibles : $nombre_centos" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

echo -e "\tEtape 2 : Installation des mises à jour"  >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

> /var/log/yum.log

yum upgrade -q -y 2> $log/erreur.log

nombre_ok=$(grep -E 'Updated:|Installed' /var/log/yum.log | wc -l)

# Si le fichier d'erreur est vide.

if [ ! -s $erreur ]

then

echo "Les paquets suivants ont été mis à jour ou installés :" >> $log/update_$jour-$heure

echo "" >> $log/update_$jour-$heure

grep -E 'Updated:|Installed' /var/log/yum.log | awk '{print $5}' >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tNombre total de paquets mis à jour ou installés : $nombre_ok" >> $log/update_$jour-$heure

else

# Si le fichier d'erreur n'est pas vide.

echo "Des erreurs ont été rencontrées :" >> $log/update_$jour-$heure

cat $erreur >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tFin du traitement le $(date +%d-%B-%Y) à $(date +%H:%M:%S)" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

mutt -s "Mises à jour du $(date +%d" "%B" "%Y) sur $HOSTNAME" $destinataire < $log/update_$jour-$heure

exit

fi
}

kernel_reboot()

{

nouveau=$(ls -t /boot/vmlinuz-* | sed "s/\/boot\/vmlinuz-//g" | head -n1)

actuel=$(uname -r)

if [ "$nouveau" != "$actuel" ];then

echo -e "Le kernel a été mis à jour, un redémarrage est nécessaire.\n\nkernel actuel : $actuel\nKernel installé : $nouveau\n" >> $log/update_$jour-$heure

fi

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

}

maj_centos

kernel_reboot

mutt -s "Mises à jour du $(date +%d" "%B" "%Y) sur $HOSTNAME" $destinataire < $log/update_$jour-$heure




