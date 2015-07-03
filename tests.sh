#!/bin/bash

# Centralisation des tests.

# Changer ici le path pour qu'il pointe au bonne endroit
heimdali() { PATH=$HOME/HEIMDALI/heimdali/build/cmd:$PATH; }

inrimage() { PATH=/usr/local/inrimage/bin:$PATH;  }


echo "**** Commande par ****"
inrimage
./test-par.sh
heimdali
./test-par.sh

echo "**** Commande cim ****"
inrimage
./test-cim.sh
heimdali
./test-cim.sh

echo "**** Commande cco ****"
echo A FAIRE
echo

echo "**** Commande tpr ****"
echo A FAIRE
echo 

echo "**** Commandes arit1 ****"
inrimage
./test-arit1.sh
./test-thresh.sh
heimdali
./test-arit1.sh
./test-thresh.sh


echo "**** Commandes arit2 ****"
inrimage
./test-arit2.sh
heimdali
./test-arit2.sh
