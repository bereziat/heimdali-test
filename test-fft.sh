#!/bin/bash
. utils

inrpath
echo "## Test inrimage"
# dft
seq 16 | cim -x 4 -y 4 > t.inr
echo "# donnee "; tpr -c t.inr
rdf t.inr r i
echo "# partie reelle"; tpr -c r
echo "# partie imaginaire"; tpr -c i

# dft inverse
idf r i a.inr b.inr
echo "# erreur reconstruction"
so t.inr a.inr | ical
echo "# stat partie imaginaire reconstruite"
ical b.inr

heimpath
echo "## Test heimdali"
rdf t.inr r.h5 i.h5
echo "# partie reelle"; tpr -c r.h5
echo "# partie imaginaire"; tpr -c i.h5

idf r.h5 i.h5 a.h5 b.h5
ls *.h5
echo "# erreur reconstruction"
so t.inr a.h5 | ical
echo "# stat partie imaginaire reconstruite"
ical b.h5


rm -f t.inr r i i.h5 r.h5 a.h5 b.h5
