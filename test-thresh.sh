#!/bin/bash
# test of arithmetic commands related to thresholding: mb, mh, muls, sba ,sha, vb vh

. common.sh

carflo 0 127 255 | /usr/local/inrimage/bin/cim -r -x 3 -y 1 > im1.$ext

# provisoire, a modifier lorsque cim sera fixée (-r)
echo 0 127 255 | /usr/local/inrimage/bin/cim -f -x 3 -y 1 > im2.inr
/usr/local/inrimage/bin/inr2h5 im2.inr im2.h5
    
testMbFloat() {
    # -b 1 not supported by Heimdali
    # mb -n 0.5 im1.$ext | par
    out=$(mb -n 0.5 im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "255 255 0"
} 

testMbFix() {
    # mb -n 0.5 im2.$ext | par
    out=$(mb -n 0.5 im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "255 255 0"
}


testMhFloat() {
    out=$(mh -n 0.5 im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "0 0 255"
} 

testMhFix() {
    out=$(mh -n 0.5 im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "0 0 255"
}

testVbCheckInterface() {
    assertTrue "Issue #65" "vb -n 0.5 0.247059 im1.$ext | par"
}

# provisoire
# itest ne sait pas lire dans stdin : issue #66
testVbReturnsFloat() {
    # always returns float values
    case $ext in
	h5)
	    assertEquals "$(vb -n 0.5 -v 0.247059 im1.$ext | par -f)" " -r"
	    assertEquals "$(vb -n 0.5 -v 0.247059 im2.$ext | par -f)" " -r"
	    ;;
	inr)
	    assertTrue "vb -n 0.5 0.247059 im1.$ext | itest -r"
	    assertTrue "vb -n 0.5 0.247059 im2.$ext | itest -r"
	    ;;
    esac
}

testVbFloat() {
    # Provisoire (issue #65)
    local v
    [ $ext = h5 ] && v="-v"
    out=$(vb -n 0.5 $v 0.247059 im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "0.247059 0.247059 1"
} 

testVbFix() {
    # Provisoire (issue #65)
    local v
    [ $ext = h5 ] && v="-v"
    out=$(vb -n 0.5 $v 0.247059 im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "0.247059 0.247059 1"
}


testVbCheckInterface() {
    assertTrue "Issue #65" "vh -n 0.5 0.247059 im1.$ext | par"
}

# provisoire
# itest ne sait pas lire dans stdin : issue #66
testVhReturnsFloat() {
    # always returns float values
    case $ext in
	h5)
	    assertEquals "$(vh -n 0.5 -v 0.247059 im1.$ext | par -f)" " -r"
	    assertEquals "$(vh -n 0.5 -v 0.247059 im2.$ext | par -f)" " -r"
	    ;;
	inr)
	    assertTrue "vh -n 0.5 0.247059 im1.$ext | itest -r"
	    assertTrue "vh -n 0.5 0.247059 im2.$ext | itest -r"
	    ;;
    esac
}

testVhFloat() {
    # Provisoire (issue #65)
    local v
    [ $ext = h5 ] && v="-v"
    out=$(vh -n 0.5 $v 0.247059 im1.$ext | tpr -c | sed 's/ $//')
    assertEquals "$out" "0 0.498039 0.247059"
} 

testVhFix() {
    # Provisoire (issue #65)
    local v
    [ $ext = h5 ] && v="-v"
    out=$(vh -n 0.5 $v 0.247059 im2.$ext | tpr -c | sed 's/ $//')
    assertEquals "Issue #63" "$out" "0 0.498039 0.247059"
}

. shunit2/src/shunit2

rm -f im?.$ext
