#!/bin/bash

set -x

echo "Lena est codée sur 1 octet:"
par lena.inr
echo "Sa dynamique est entre 0.117 et 0.937:"
ical lena.inr
cat <<EOF
ical a lu l'image comme si elle était en flottant. En fait elle considère
qu'elle est a virgule fixe, avec des valeurs comprises entre 0 et 2**n-1
ou n est la taille de codage en bit d'une valeur. Donc les statistiques
de l'image en niveau de gris serait (il manque l'arrondi!):
$(echo 0.117647*255 | bc)  $(echo 0.499636*255 | bc)  $(echo 0.937255*255 | bc)
EOF

echo "Conversion en virgule flottante:"
cco -r lena.inr | par
cco -r lena.inr | ical

cat <<EOF
Règle cco n°1 : conversion de virgule fixe vers virgule flottante:
  valeur_vfloat = valeur_vfixe/(2**taille_de_codage-1)

  la taille de codage est en bit.
EOF


echo "Reconversion en virgule fixe:"
cco -r lena.inr | cco -f | par
cco -r lena.inr | cco -f | ical

cat <<EOF
Règle cco n°2:  conversion virgule flottante vers virgule fixe:
   valeur_vfixe = valeur_vfloat * (2**taille_de_codage-1)

ok c'est la réciproque de la règle 1.
Conséquence, toutes les valeurs flottantes plus grandes que 1 sont
perdus et mise à 1 et donc à la valeur max autorisée par le
codage en virgule flottante.

Par exemple:
lena a un min a 0.117647. si je multiplie par 8.5, je me ramène à 1:
EOF

sc -n 8.5 lena.inr | cco -r > lena-85r.inr
par lena-85r.inr
ical lena-85r.inr

cat <<EOF
la plus petite valeur de lena-r est 1, donc l'image est entierement mise à 255 après
conversion:
EOF
cco -f  lena-85r.inr | par
cco -f  lena-85r.inr | ical

cat <<EOF


Les routines de conversion float/fixe sont assurées par la routine
inrimage cnvtbg(): voir man cnvtbg. Dans la man page, on voit aussi
que les images inrimage en virgule fixe ont un exposant, par défaut
nul, ce qui signifie qu'on multiplie par 1 (et qu'on ne change rien)
on voit aussi que les images à virgule fixe peuvent être signée.
(voir aussi man Intro).

Les options de format de cco (et qui sont communes à d'autres commandes
inrimage) sont décrite dans man Inrimage /OPTIONS DE FORMAT

Autres conversions

EOF

echo "Conversion -o 1 vers -o 2 (le -f est explicite):"
cco lena.inr -o 2 > lena-2o.inr
echo "et réciproquement "
cco lena-2o.inr -o 1 | so lena.inr | ical

echo "Conversion -r vers -o 2 (le -f est explicite):"
cco lena.inr -r > lena-r.inr
cco lena-r.inr -o 2 > lena-r2o.inr
echo "et réciproquement "
cco lena-r2o.inr -r | so lena.inr | ical

cat <<EOF

Cette série de conversion n'a pas changé les statistiques de l'image:
EOF
ical lena.inr lena-2o.inr lena-r.inr lena-r2o.inr


echo
echo "Conversion de n'importe quoi vers -b 1 (le -f est explicite): il s'agit d'une image binaire"
cco lena-r.inr -b 1 > lena-rb.inr
cco lena.inr -b 1 > lena-fb.inr
so  lena-?b.inr | ical


cat <<EOF

Les codage que l'on souhaite garder pour Heimdali

-r         : flottant simple précision
-r -o 8    : flottant double précision
-o 1 ou -f : fixe sur 1 octet
-o 2       : fixe sur 2 octets
-o 4       : fixe sur 4 octets
-b 1       : fixe sur 1 bit

optionnel:
-e xx : gestion de l'exposant (xx est l'exposant)
-s    : image signée (virgule fixe)
-b xx : codage bit quelconque
EOF
