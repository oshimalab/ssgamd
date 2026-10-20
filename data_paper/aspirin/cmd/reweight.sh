#!/bin/bash

## CV
cat << EOF > trj_analysis.inp
[INPUT]
prmtopfile     = ../system.prmtop
ambcrdfile     = ../system.inpcrd
 
[OUTPUT]
comdisfile = cv.dat 
 
[TRAJECTORY]
trjfile1       = run1.dcd
mdout_period1  = 1
ana_period1    = 1
trj_format     = DCD
trj_type       = COOR
trj_natom      = 0

[SELECTION]
group1 = rno:1-7
group2 = rno:8

[OPTION]
check_only     = NO
com_distance1 = 1 2
EOF
trj_analysis ./trj_analysis.inp

## Calc PMF
./calc_pmf.py
