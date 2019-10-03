#!/bin/bash
# Script mises à jour Centos 7
# Le script va lister le nombre et le nom des paquets qui seront mis à jour.
# Il va ensuite les installer et pour terminer envoyer un mail récapitulatif.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

liste=$(yum -q check-update | tail -n+2 | awk {'print $1'})
nombre=$(yum -q check-update | tail -n+2 | wc -l)
jour=$(date +'%d %B %Y')
sujet="Mises à jour disponibles sur $HOSTNAME"
destinataire="mail@admin.com"
expediteur="notifications_updates@admin.com"

yum check-update > /dev/null

maj(){
echo -e "------------------------------------------------------------------------------------------------------\n"
echo -e "\t$jour : $nombre mises à jour disponibles sur $HOSTNAME\n"
echo -e "------------------------------------------------------------------------------------------------------\n"
for i in $liste;do
actuelle=$(yum list installed $i | awk {'print $1,$2'} | tail -n+3)
maj=$(yum -q check-update | tail -n+2 | awk {'print $1,$2'} | grep -w $i)
echo -e "$i :\nInstallé : $actuelle\nCandidat : $maj\n"
echo -e "------------------------------------------------------------------------------------------------------\n"
done
}

if [ $nombre -ne 0 ];then

maj | mutt -s "$sujet" $destinataire < $log/update_$jour-$heure

else

exit

fi
