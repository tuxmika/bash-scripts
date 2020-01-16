#!/bin/bash
# Le script va simplement renommer les photos avec le nom donné en paramètre.
# Celui-ci fonctionne avec des fichiers autres que des photos.
# Les photos auront des numéros séquentiels qui seront entre parenthèses.
# Le renommage des noms de fichiers comprenant des espaces fonctionne avec le script.
# Licence CC BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# On entre le nom de renommage souhaité.

echo -n "Entrer un nom : "

read nom

# Le 1er numéro séquentiel sera le numéro 1.

compteur=1

# On se place dans le répertoire donné en paramètre.

cd $1

# Les images sont renommées avec le nom entré en paramètre.
# L'incrémentation séquentielle se fait entre parenthèses.
# On préserve l'extension du fichier.

for images in *

do

extension=${images##*.}

mv "$images" "$nom(${compteur}).$extension"

compteur=$(($compteur + 1))

done

