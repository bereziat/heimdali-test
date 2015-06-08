#!/bin/bash
. utils

set -e

cmpimg() {
    ical $1 > /tmp/ical1
    ical $2 > /tmp/ical2
    if cmp /tmp/ical? ; then echo "$1 == $2"; else
	echo "$1 != $2"
	par $*
	ical $*
    fi
}

echo "#Test de la commande hconv (convertion de format d'image)"

codage=("-f" "-f -o 2" "-f -o 4" "-r")
codage=("-r -o 8")


for cod in "${codage[@]}"; do
    cco $cod lena.inr >len.inr
    
    echo "## Inrimage scalaire monoplan ($cod) vers hdf5:"
    heimpath
    hconv len.inr len.h5
    set +x
    cmpimg len.*

    echo "## Inrimage scalaire multiplans ($cod) vers hdf5:"
    inrpath
    create $(par len.inr -x -y -f -o) -z 5 > len5z.inr
    for i in {1..5}; do
	inrcat len.inr
    done >> len5z.inr
    heimpath
    hconv len5z.inr len5z.h5
    set +x
    cmpimg len5z.*


    echo "## Inrimage vectorielle monoplan ($cod) vers hdf5:"
    inrpath
    raz $(par len.inr -x -y -f -o) -v 2 > len2v.inr
    for i in {1..2}; do
	melg len.inr -ivo $i len2v.inr
    done
    heimpath
    hconv len2v.inr len2v.h5
    set +x
    cmpimg len2v.*


    echo "## Inrimage vectorielle multiplans ($cod) vers hdf5:"
    inrpath
    create $(par len.inr -x -y -f -o) -z 5 -v 2 > len2v5z.inr
    for i in {1..5}; do
	inrcat len2v.inr
    done >> len2v5z.inr
    par len2v5z.inr
    heimpath
    hconv len2v5z.inr len2v5z.h5
    set +x
    cmpimg len2v5z.*


done


# autres codages (-e, -s, -b)
