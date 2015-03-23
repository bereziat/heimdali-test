#!/bin/bash

if which inrinfo ; then
    inrpath=$(which inrinfo)
    inrpath=${inrpath%/inrinfo}
fi
if which hconv ; then    
    heimpath=$(which hconv)
    heimpath=${heimpath%/hconv}
fi

set -e

case $1 in
    -h|--help)
	cat <<EOF
Usage is:
./tests-format [inrimage-bin-path] [heimdali-bin-path]
EOF
	;;
esac

case $# in
    1) inrpath=$1;;
    2) inrpath=$1; heimpath=$2;;
esac



OLDPATH=$PATH
toinr () { PATH=$inrpath:$OLDPATH; }
toheim () { PATH=$heimpath:$OLDPATH; }


toinr

cco lena.inr.gz -r > lr.inr
cco lena.inr.gz -r -o 8 > ld.inr

for i in 1 2 4 ; do
    cco lena.inr.gz -o $i > lo$i.inr
    cco lena.inr.gz -o $i -s > lo${i}s.inr
done

for i in 1 2 3 12; do
    cco lena.inr.gz -b $i > lb$i.inr
    cco lena.inr.gz -b $i -p > lp$i.inr
    cco lena.inr.gz -b $i > lb${i}s.inr
done

echo %%% Simple precision
par lr.inr
ical lr.inr
toheim
par lr.inr
ical lr.inr

echo %%% Double precision
toinr
par ld.inr
ical ld.inr
toheim
par ld.inr
ical ld.inr

echo %%% 1, 2 or 4 bytes unsigned
for i in 1 2 4; do
    toinr
    par lo$i.inr
    ical lo$i.inr
    toheim
    par lo$i.inr
    ical lo$i.inr
done

echo %%% 1, 2 or 4 bytes signed
for i in 1 2 4; do
    toinr
    par lo${i}s.inr
    ical lo${i}s.inr
    toheim
    par lo${i}s.inr
    ical lo${i}s.inr
done

echo %%% 1, 2, 3 or 12 bits unsigned
for i in 1 2 3 12; do
    toinr
    par lb$i.inr
    ical lb$i.inr
    toheim
    par lb$i.inr
    ical lb$i.inr
done

echo %%% 1, 2, 3, or 12 bits signed
for i in 1 2 3 12; do
    toinr
    par lb${i}s.inr
    ical lb${i}s.inr
    toheim
    par lb${i}s.inr
    ical lb${i}s.inr
done

echo %%% 1, 2, 3, or 12 bits packed
for i in 1 2 3 12; do
    toinr
    par lp$i.inr
    ical lp$i.inr
    toheim
    par lp$i.inr
    ical lp$i.inr
done


read -p "Clean ? (y/N) " yesno
case $yesno in
    y)
	rm -f l?.inr
	rm -f l??.inr
	rm -f l??.inr
	rm -f l??s.inr
	rm -f l?12*.inr
	;;
esac

