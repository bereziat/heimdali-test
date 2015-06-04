#!/bin/bash

. common.sh

# test if par read inrimage
testParInr()
{
    assertTrue "par imgs/lena.inr"
}
# test if par correctly returns false
testParFalse()
{
    assertFalse "par imgs/lena.h"
}
# test if par read hdf5
testParHdf5()
{
    assertTrue "Cannot read HDF5" "par imgs/lena.h5"
}
# test if par correctly returns true from stdin
testParStdin()
{
    assertTrue "par <imgs/lena.$ext"
}
# test par switches
testParSwitches()
{
    res=`par -x imgs/lena.$ext`
    assertEquals ' -x 256' "$res"
    res=`par -y imgs/lena.$ext`
    assertEquals ' -y 256' "$res"
    res=`par -z imgs/lena.$ext`
    assertEquals ' -z 1' "$res"
    res=`par -v imgs/lena.$ext`
    assertEquals ' -v 1' "$res"
    res=`par -o imgs/lena.$ext`
    assertEquals ' -o 1' "$res"
    res=`par -f imgs/lena.$ext`
    assertEquals ' -f' "$res" 
}
# ce test échoue, ça me fera un exo de patch (a faire avec David)
testParOutput(){
    res=`par imgs/lena.$ext | sed 's/-F=Inrimage//;s/-hdr=[1-8]//' | tr '\t' ' ' | tr -s ' '`
    assertEquals "Issue #52" "$res" 'imgs/lena.inr -x 256 -y 256 -f -o 1'
}



# end of tests
. shunit2/src/shunit2
