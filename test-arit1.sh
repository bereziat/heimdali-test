#!/bin/bash
# test of arithmetic command with one image as input: bi, sc, sd, lo, ra, car, mo

. common.sh

echo -1 0 1 | cim -r -x 3 -y 1 > im1.$ext

# provisoire, a modifier lorsque cim sera fixée (-r)
echo 0 127 255 | /usr/local/inrimage/bin/cim -f -x 3 -y 1 > im2.inr
/usr/local/inrimage/bin/inr2h5 im2.inr im2.h5

testBiFloat() {
    out=$(bi im1.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals  "$out" "0 1 2"
}

testBiFix() {
    out=$(bi im2.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "1 1.49804 2"
}

testScFloat() {
    out=$(sc im1.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals "$out" "-1 0 1"    
}

testScFix() {
    out=$(sc im2.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals "$out" "0 0.498039 1"
}

testSdFloat() {
    out=$(sd im1.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals "$out" "-1 0 1"
}

testSdFix() {
    out=$(sd im2.$ext -n 1 | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "0 0.498039 1"
}

testCarFloat() {
    out=$(car im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "1 0 1"
}

testCarFix() {
    out=$(car im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "0 0.248043 1"
}

testRaFloat() {
    out=$(car im1.$ext | ra | tpr -c | sed 's/ $//')
    assertEquals "$out" "1 0 1"
}

testRaFix() {
    out=$(ra im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "0 0.705719 1"
}

testExpFloat() {
    out=$(exp im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "0.367879 1 2.71828"
}

testExpFix() {
    out=$(exp im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "1 1.64549 2.71828"
}

testLoFloat() {
    out=$(bi -n 1 im1.$ext | lo | tpr -c | sed 's/ $//')
    assertEquals "$out" "-inf 0 0.693147"
}

testLoFix() {
    out=$(lo im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "-inf -0.697076 0"
}

testMoFloat() {
    # mo is in fact an absolute value
    out=$(mo im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "1 0 1"
}

testMoFix() {    
    # fixed images are read as usual and result is always in float format
    assertEquals "toto" $(cco  -f im1.$ext |  mo | par -f) '-r'

    out=$(cco  -f im1.$ext |  mo | tpr -c | sed 's/ $//')
    assertEquals "$out" "0 0 1"
}

# tests sur dimensions à faire.

. shunit2/src/shunit2

rm -f im?.$ext
