#!/bin/bash


## CV
for i in {1..12}; do
cat << EOF > rmsd_analysis.inp
[INPUT]
prmtopfile     = ../system.prmtop
ambcrdfile     = ../system.inpcrd
ambreffile     = ../system.inpcrd

[OUTPUT]
rmsfile     = cv${i}.dat

[TRAJECTORY]
trjfile1       = run${i}.dcd
mdout_period1  = 1
ana_period1    = 1
trj_format     = DCD
trj_type       = COOR+BOX
trj_natom      = 0

[SELECTION]
group1 = rno:2-21 and an:CA

[FITTING]
fitting_method = TR+ROT
fitting_atom   = 1               # atom group
zrot_ngrid     = 10              # number of z-rot grids
zrot_grid_size = 1.0             # z-rot grid size
mass_weight    = NO              # mass-weight is not applied

[OPTION]
check_only     = NO              # only checking input files (YES/NO)
allow_backup   = NO              # backup existing output files (YES/NO)
analysis_atom  = 1               # atom group
EOF
rmsd_analysis ./rmsd_analysis.inp
done


## Merge
cp /dev/null cv.dat
cp /dev/null out.dat
for i in {1..12}; do
	cat cv${i}.dat >> cv.dat
	grep "^INFO" run${i}.log >> out.dat
done


## Calc reweighted PMF
./calc_pmf_1d.py -t 300.0 -c 0.0 -n 1800000 --Xmin 0.0 --Xmax 15.0 --Xdel 0.1 --cv_file cv.dat --out_file out.dat
