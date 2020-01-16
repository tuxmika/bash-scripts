#!/bin/bash
# Script surveillance site Web
# Celui-ci qui va analyser le code de statut HTTP de vos sites web ( ok, moved permanently, not found etc...) et vous envoyer un mail si le statut n'est pas ok ( code 200 ).

Le script va utiliser la commande curl ( Client URL Request Library ) pour effectuer des requêtes HTTP.
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

sites="http://www.xxxx.fr http://www.yyyyy.fr" 
mail=admin@domain.com
sujet="Statut HTTP" 

compteur=0 

while true 

   do 

# On attend 30 secondes entre chaque check 

sleep 30 

for i in $sites 

    do 

test=$(curl -Is $i | awk '/HTTP/ {print $2}') 

# si le code status n'est pas 200 

if [[ $test -ne 200 ]];then 

# On incrémente alors le compteur de 1 

compteur=$((compteur+1)) 

# Si le status n'est pas ok 3 fois d'affilée, le script effectuera un ping du domaine pour vérifier que celui-ci répond, l'alerte sera donnée et le compteur sera remis à 0.

if [ $compteur -eq 3 ];then 

statut=$(curl -Is $i | awk '/HTTP/ {print $2,$3,$4}') 

domaine=$(echo $i | awk -F'/' '{print $3}') 

ping=$(ping -c 3 $domaine) 

date=$(date '+%d-%m-%Y %H:%M:%S') 

# On envoie le mail d'alerte et on remet le compteur à 0 

echo -e "$heure $i : $statut\n\n$ping" | mail -s "$date : $sujet" $mail 

compteur=0 

      fi 

    fi 

  done 

done
