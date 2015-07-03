#!/bin/bash
# test of arithmetic commands having two images as input: ad, so, mu, di, min, max

. common.sh

echo -1 0 1 -2 0 2 -1 0 1 | cim -r -x 3 -y 3 > im1.$ext
echo  1 1 1 1 1 1 1 1 1 | cim -r -x 3 -y 3 > im2.$ext

# Provisoire, en attendant que cim -f soit fixé
echo  0 63 127 190 254  | cim -r -x 5 -y 1 | sd -n 255 | cco -f > im3.$ext
echo  255 190 127 63 1  | cim -r -x 5 -y 1 | sd -n 255 | cco -f > im4.$ext

testArit2StdinAndOutFormat() {
    for cmd in ad so mu di min max; do
	assertTrue "test stdin1 $cmd" "$cmd <im1.$ext - im2.$ext | itest -r "
	assertTrue "test stdin2 $cmd (issue #84: wrong usage)" "$cmd im1.$ext <im2.$ext | par "
    done
}

testAdFloat() {
    out=$(ad im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "0 1 2 -1 1 3 0 1 2 "
}

testAdFix() {
    out=$(ad im3.$ext im4.$ext | tpr -c -l 1 $fmt%f | tr '\n' ' ')
    res=$(carflo 255 253 254 253 255)
    assertEquals "Issue #63" "$out" "$res"
}

testSoFloat() {
    out=$(so im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "-2 -1 0 -3 -1 1 -2 -1 0 "
}

testSoFix() {
    out=$(so im4.$ext im3.$ext | tpr -c -l 1 $fmt%f | tr '\n' ' ')
    res="$(carflo 255 127 0)-$(carflo 127)-$(carflo 253)"
    assertEquals "$out" "$res"
}


testMuFloat() {
    out=$(mu im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "-1 0 1 -2 0 2 -1 0 1 "
}

testMuFix() {
    out=$(mu im4.$ext im3.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "0 0.184083 0.248043 0.184083 0.00390619 "
}

testDiFloat() {
    out=$(di im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "-1 0 1 -2 0 2 -1 0 1 "
}

testDiFix() {
    out=$(di im3.$ext im4.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "Issue #??" "$out" "0 0.331579 1 3.01587 254 "
}

testMinFloat() {
    out=$(min im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "$out" "-1 0 1 -2 0 1 -1 0 1 "
}

testMinFix() {
    out=$(min im4.$ext im3.$ext | tpr -c -l 1 $fmt%f | tr '\n' ' ')
    res="$(carflo 0 63 127 63 1)"
    assertEquals "$out" "$res"
}

testMaxFloat() {
    out=$(max im1.$ext im2.$ext | tpr -c -l 1 | tr '\n' ' ')
    assertEquals "Issue #??" "$out" "1 1 1 1 1 2 1 1 1 "
}

testMaxFix() {
    out=$(max im4.$ext im3.$ext | tpr -c -l 1 $fmt%f | tr '\n' ' ')
    res="$(carflo 255 190 127 190 254)"
    assertEquals "$out" "$res"
}



# tests identiques à faire sur les autres commandes (qui souffrent du même problème)

# tests sur stdin/stdout
# tests sur dimensions à faire (-x -y -z -v).


. shunit2/src/shunit2

rm -f im?.$ext
