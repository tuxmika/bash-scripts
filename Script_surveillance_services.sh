#!/bin/bash
# Script surveillance services
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

liste="service1 service2 service3"
for service in $liste
do
pgrep $service > /dev/null
if [ $? -ne 0 ]
then
echo -e "\033[1;31mservice $service arreté\033[0m"
else
echo -e "\033[1;32mservice $service démarré\033[0m"
ps -eo comm,pid,lstart | grep $service
fi
done
