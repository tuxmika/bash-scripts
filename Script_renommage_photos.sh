#!/bin/bash
# Le script va simplement renommer les photos avec le nom donné en argument.
# Les photos auront des numéros séquentiels qui seront entre parenthèses.
# Le renommage des noms de fichiers comprenant des espaces fonctionne avec le script.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# On entre le nom de renommage souhaité.

echo -n "Entrer un nom : "

read nom

compteur=1

# On se place dans le répertoire donné en paramètre.

cd $1

# On renomme les images.

for images in *

do

extension=${images##*.}

mv "$images" "$nom(${compteur}).$extension"

compteur=$(($compteur + 1))

done

