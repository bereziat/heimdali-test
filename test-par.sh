#!/bin/bash

echo "Unit tests using $(inrinfo | head -1)"
echo "==="
echo ""

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
# test if par correctly returns true
testParTrue()
{
    assertTrue "par imgs/lena.h5"
}
# test if par correctly returns true
testParStdin()
{
    assertTrue "par <imgs/lena.h5"
}
# test par switches
testParSwitches()
{
    res=`par -x imgs/lena.h5`
    assertEquals ' -x 256' "$res"
    res=`par -y imgs/lena.h5`
    assertEquals ' -y 256' "$res"
    res=`par -z imgs/lena.h5`
    assertEquals ' -z 1' "$res"
    res=`par -v imgs/lena.h5`
    assertEquals ' -v 1' "$res"
    res=`par -o imgs/lena.h5`
    assertEquals ' -o 1' "$res"
    res=`par -f imgs/lena.h5`
    assertEquals ' -f' "$res" 
}
# ce test échoue, ça me fera un exo de patch (a faire avec David)
testParOutput(){
    res=`par imgs/lena.inr`
    assertEquals "$res" 'imgs/lena.inr -x 256	-y 256	-f	-o 1'
}



# end of tests
. shunit2/src/shunit2
