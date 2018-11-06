# !/bin/bash
# Script de notification de mises à jour Debian / Centos
# Licence MIT ( http://choosealicense.com/licenses/mit/ )

# Variables
jour=$(date +'%d %B %Y')
ip=$(hostname -I)
sujet="Mises à jour disponibles sur $HOSTNAME"
destinataire="mail@admin.fr"

# On teste la présence du fichier /etc/debian_version
# Si celui-ci est présent, alors on vérifie les mises à jour pour Debian

if [ -f /etc/debian_version ]; then
liste_debian=$(apt-get -s dist-upgrade | grep "Inst" | awk '{print $2}')
nombre_debian=$(apt-get -s dist-upgrade | grep "Inst" | awk '{print $2}'| wc -l)
expediteur="mail@admin.fr"
apt-get -qq update && apt-get -s dist-upgrade > /dev/null
maj_debian(){
echo -e "-------------------------------------------------------------------------------------------------\n"
echo -e "\t$jour : $nombre_debian mises à jour disponibles sur $HOSTNAME ($ip)\n"
for i in $liste_debian ;do
versions=$(apt-cache policy $i | head -3)echo -e "-------------------------------------------------------------------------------------------------\n"
echo -e "$versions\n"
echo -e "informations sur le paquet:
https://packages.debian.org/fr/stretch/$ {i}\n"
done
echo -e "-------------------------------------------------------------------------------------------------\n"
}
if [ $nombre_debian -ne 0 ]; then
maj_debian | mail -s "$sujet" -r "NOTIFICATIONS_UPDATES<$expediteur>" $destinataire
fi

# Si le fichier /etc/debian_version n’est pas présent, alors on vérifie les mises à jour pour Centos

else
yum check-update > /dev/null
liste_centos=$(yum -q check-update | tail -n+2 | awk {'print $1'})
nombre_centos=$(yum -q check-update | tail -n+2 | wc -l)
expediteur="mail@admin.fr"
maj_centos(){
echo -e "------------------------------------------------------------------------------------------------------\n"echo -e "\t$jour : $nombre_centos mises à jour disponibles sur $HOSTNAME ($ip)\n"
echo -e "------------------------------------------------------------------------------------------------------\n"
for i in $liste_centos ;do
actuelle=$(yum list installed $i | awk {'print $1,$2'} | tail -n+3)
maj=$(yum -q check-update | tail -n+2 | awk {'print $1,$2'} | grep -w $i)
echo -e "$i :\nInstallé : $actuelle\nCandidat : $maj\n"
echo -e "------------------------------------------------------------------------------------------------------\n"
done
}
if [ $nombre_centos -ne 0 ]; then
maj_centos | mail -s "$sujet" -r "NOTIFICATIONS_UPDATES<$expediteur>" "$destinataire"
else
exit
fi
fi
