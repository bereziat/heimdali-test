#!/bin/bash

# required: cim, sd, ical

. common.sh

testConv() {
    echo  1 1 1 1 1 1 1 1 1 | cim -x 3 -y 3 -r | sd -n 9 > toto.$ext
    assertTrue "Issue #55 (conv cannot write to stdout)" "conv imgs/lena.$ext toto.$ext >/tmp/t$$.$ext"
    conv imgs/lena.$ext toto.$ext /tmp/t$$.$ext
    res=$(ical /tmp/t$$.$ext | tr -s ' ')
    assertEquals "Issues #55 (wrong result) and #53 (wrong ical print format)" "$res" "0.137255 0.499666 0.891939"
    rm -f toto.$ext
    rm -f /tmp/t$$.ext
}

# end of tests
. shunit2/src/shunit2
