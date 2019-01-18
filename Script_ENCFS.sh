#!/bin/bash


annulation()
{

if [ $? -ne 0 ]

then

     zenity --info --title "Annulation" --text "<b>Opération annulée</b>"

exit

fi

}

clear
echo "-----------------------------------------------------------------------------"
echo -e "\033[15C SCRIPT DE MONTAGE / DEMONTAGE ENCFS"
echo "-----------------------------------------------------------------------------"

echo "q: Quitter"
echo -e "r: Retour\n"
echo "1: Montage"
echo -e "2: Demontage\n"

until [ "$menu" = "q" ]; do
echo -n "choix: "
read menu
if [ "$menu" = "q" ]; then
echo "Au revoir" $exit
fi
if [ "$menu" = "r" ]; then
exec $0
fi

case $menu in

# On vérifie que si le dossier est monté

1) ok=`ssh user@adresse_ip cat /proc/mounts | tail -1 | awk '{print $1}'`

# Si le dossier est déjà monté, alors avertissement

if [[ "$ok" == "encfs" ]];then

     echo -e "\e[0;31mLe dossier est deja monté\033[0m"

else

# Sinon on monte le dossier

     sshfs user@adresse_ip:/home/user/dossier_déchiffré /home/user/sshfs_local -o nonempty

zenity --password --title='EncFS' | ssh user@adresse_ip encfs /home/user/dossier_chiffré /home/user/dossier_déchiffré -o nonempty

annulation

# Si le montage s'est bien passé, une confirmation s'affiche

if [ $? -eq 0 ];then

     echo -e "\e[1;32mLe montage a été effectué\033[0m"

   fi

fi;;

# On vérifie que si le dossier est démonté

2) ok=`ssh user@adresse_ip cat /proc/mounts | tail -1 | awk '{print $1}'`

# Si le dossier est déjà démonté, alors avertissement

if [[ "$ok" != "encfs" ]];then

   echo -e "\e[0;31mLe dossier est deja démonté\033[0m"

else

# Sinon on démonte le dossier

   ssh user@adresse_ip fusermount -u /home/user/dossier_déchiffré

fusermount -u /home/user/sshfs_local

# Si le démontage s'est bien passé, une confirmation s'affiche

if [ $? -eq 0 ];then

      echo -e "\e[1;32mLe démontage a été effectué\033[0m"

       fi

    fi;;

 esac

done
