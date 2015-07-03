#!/bin/bash
# test of cco command and momentarly tpr 
source common.sh

echo 0 0.5 1 | cim -x 3 -r > im1.$ext
echo -1 -0.5 0 0.5 1 | cim -x 5 -r > im2.$ext


# Issue d'arrondi !
testCcoPositiveFloatTo1o() {
    assertTrue "cco im1.$ext -f | itest -f -o 1"
    assertEquals "issue #85 (round)" "$(cco im1.$ext -f | tpr -c | sed 's/ $//')" "0 128 255"
}

testCcoNegativeFloatTo1o() {
    assertTrue "cco im2.$ext -o 1 | itest -f -o 1"    
    assertEquals "issue #85 (round)" "$(cco im2.$ext -f | tpr -c | sed 's/ $//')" "0 0 0 128 255"
}

testCco1oToFloat() {
    cco -f im1.$ext > im3.$ext
    assertTrue "cco -r im3.$ext | itest -r -o 4"
    assertEquals "$(cco -r im3.$ext | tpr -c | sed 's/ $//')" "0 0.501961 1"
}

testCco1oTo2o() {
    assertTrue "cco -o 2 im3.$ext | itest -f -o 2"
    assertEquals "$(cco -o 2 im3.$ext | tpr -c | sed 's/ $//')" "0 0.501961 1"
    # tpr issue
    assertEquals "issue #87 (tpr -f %d)" "$(cco -o 2 im3.$ext | tpr -c $fmt%d | sed 's/ $//')" "0 32896 65535"
}

source shunit2/src/shunit2
rm -f im?.$ext
