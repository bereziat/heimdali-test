#!/bin/bash

. common.sh

testCim1o() {
    echo  1 2 3 4 5 6 | cim -x 3 -y 2 > /tmp/t$$.$ext
    x=$(par /tmp/t$$.$ext -x -y -z -v -f -o | tr -s ' ' | tr '\t' ' ')
    assertEquals "Issue #48" "$x" " -x 3 -y 2 -v 1 -z 1 -o 1 -f"
    rm /tmp/t$$.$ext
}

testCim4o() {
    echo  1 2 3 4 5 6 | cim -x 3 -y 2 -r > /tmp/t$$.$ext
    x=$(par /tmp/t$$.$ext -x -y -v -z -f -o | tr -s ' ' | tr '\t' ' ')
    assertEquals "$x" " -x 3 -y 2 -v 1 -z 1 -o 4 -r"
    rm /tmp/t$$.$ext
}

. shunit2/src/shunit2
