#!/bin/bash
PATH=inr2h5:$PATH
. utils

inrpath
[ -f long.inr.gz ] && gunzip long.inr.gz
time inr2h5 long.inr long1.h5
heimpath
time hconv long.inr long2.h5
ls -l long*

inrpath
gzip long.inr
time ical long.inr.gz
time ical long1.h5

heimpath
#time ical long.inr.gz
time ical long1.h5
