#!/bin/bash

case $# in
    0)
	cat <<EOF
Performs some tests on inr2h5/h52inr commands
Usage is: $0 (float|double|unsigned|signed|bits|packed|exponent)
EOF
	exit
	;;
esac

set -x

extg ../lena.inr >lena.inr -y 200

case $1 in
    float)
	echo "####### Float simple precision #######"
	cco -r lena.inr | ./inr2h5 - lena.h5
	h5dump lena.h5 | grep 'Voxel' -A10
	./h52inr lena.h5 | so lena.inr | ical
	;;

    double)
	echo "####### Float double precision #######"
	cco -r lena.inr -o 8 | ./inr2h5 - lena.h5
	h5dump lena.h5 | grep 'Voxel' -A10
	# 'so' do not deal with double precision
	./h52inr lena.h5 | cco -r | so lena.inr | ical
	;;

    unsigned)
	for nbytes in 1 2 4; do
	    echo "####### Unsigned with " $nbytes " byte(s) #######"
	    cco -o $nbytes lena.inr | ./inr2h5 - lena.h5
	    h5dump lena.h5 | grep 'Voxel' -A10
	    ./h52inr lena.h5 | so lena.inr | ical
	done
	;;

    signed)
	for nbytes in 1 2 4; do
	    echo "####### Signed with " $nbytes " byte(s) #######"
	    cco -s -o $nbytes lena.inr | ./inr2h5 - lena.h5
	    h5dump lena.h5 | grep 'Voxel' -A10
	    ./h52inr lena.h5 | so lena.inr | ical
	done
	;;

    bits)	
	for bits in 1 2 3 4 5 6 7 9 10 11 12 ; do
	    echo "####### Unsigned with " $bits " bit(s) #######"
	    cco -b $bits lena.inr > lena-bits.inr
	    ./inr2h5 lena-bits.inr lena.h5
	    h5dump lena.h5 | grep 'Voxel' -A10
	    ./h52inr lena.h5 | so lena-bits.inr | ical
	done
	;;

    packed)
	for bits in 1 2 3 4 5 6 7 9 10 11 12 ; do
	    echo "####### Packed with " $bits " bit(s) #######"
	    cco -p -b $bits lena.inr > lena-bits.inr
	    ./inr2h5 lena-bits.inr lena.h5
	    h5dump lena.h5 | grep 'Voxel' -A10
	    ./h52inr lena.h5 | so lena-bits.inr | ical
	done
	;;

    exponent)
	for exp in -1 0 1 ; do
	    echo "####### Unsigned with exponent " $exp " #######"
	    cco -e $exp lena.inr | ./inr2h5 - lena.h5
	    cco -e $exp lena.inr | par
	    cco -e $exp lena.inr | cpar -n | grep EXP
	    h5dump lena.h5 | grep exponent -A5
	    ./h52inr lena.h5 | par
	    ./h52inr lena.h5 | cpar -n | grep EXP
	done
	for exp in -1 0 1 ; do
	    echo "####### Signed with exponent " $exp " #######"
	    cco -s -e $exp lena.inr | ./inr2h5 - lena.h5
	    cco -s -e $exp lena.inr | par
	    cco -s -e $exp lena.inr | cpar -n | grep EXP
	    h5dump lena.h5 | grep exponent -A5
	    ./h52inr lena.h5 | par
	    ./h52inr lena.h5 | cpar -n | grep EXP
	done

	;;
    
    clean)
	rm -f lena-bits.inr lena.inr lean.h5
	;;
    *)
	$0
esac

# signed bits (packed), scale, biais, history

