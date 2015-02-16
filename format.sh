#!/bin/bash

if which inrinfo ; then
    inrpath=`inrinfo --prefix`/bin

    
    
    source activate heim
    inrtoh5 lena.inr lena.h5
    par lena.h5



fi
