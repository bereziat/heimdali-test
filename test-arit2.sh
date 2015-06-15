#!/bin/bash
# test of arithmetic commands having two images as input: ad, so, mu, di, min, max

. common.sh

echo -1 0 1 -2 0 2 -1 0 1 | cim -r -x 3 -y 3 > im1.$ext
echo  1 1 1 1 1 1 1 1 1 | cim -r -x 3 -y 3 > im2.$ext

echo  1 1 1 1 1 1 1 1 1 | cim -r -x 3 -y 3 | sd -n 255 | cco -f > im3.$ext
echo  2 2 2 2 2 2 2 2 2 | cim -r -x 3 -y 3 | sd -n 255 | cco -f > im4.$ext

testAdFloat() {
    out=$(ad im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "0 1 2 -1 1 3 0 1 2 "
}

testAdFix() {
    out=$(ad im3.$ext im4.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "Issue #63" "$out" "0.0117647 0.0117647 0.0117647 0.0117647 0.0117647 0.0117647 0.0117647 0.0117647 0.0117647 "
}

# tests identiques à faire sur les autres commandes (qui souffrent du même problème)

# tests sur dimensions à faire.

. shunit2/src/shunit2

rm -f im?.$ext
