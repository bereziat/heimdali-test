#!/bin/bash

# Centralisation des tests.

# Changer ici le path pour qu'il pointe au bonne endroit
heimdali() { PATH=$HOME/HEIMDALI/heimdali/build/cmd:$PATH; }

inrimage() { PATH=/usr/local/inrimage/bin:$PATH;  }


inrimage
./test-par.sh
heimdali
./test-par.sh


inrimage
./test-cim.sh
heimdali
./test-cim.sh


inrimage
./test-thresh.sh
heimdali
./test-thresh.sh
