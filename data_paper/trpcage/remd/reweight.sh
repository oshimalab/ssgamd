#!/bin/bash

## Sort
cat << EOF > remd_convert.inp
[INPUT]
prmtopfile = ../system.prmtop
ambcrdfile = ../system.inpcrd
remfile    = run1_rep{}.rem     # REMD parameter ID file
dcdfile    = run1_rep{}.dcd     # DCD file
logfile    = run1_rep{}.log     # REMD energy log file
 
[OUTPUT]
pdbfile        = run1.pdb      # PDB file
trjfile        = run1_par{}.dcd    # trajectory file
logfile        = run1_par{}.log    # REMD energy log file
 
[SELECTION]
group1         = all             # selection group 1
 
[FITTING]
fitting_method = NO              # NO/TR+ROT/TR/TR+ZROT/XYTR/XYTR+ZROT
fitting_atom   = 1               # atom group
zrot_ngrid     = 10              # number of z-rot grids
zrot_grid_size = 1.0             # z-rot grid size
mass_weight    = NO              # mass-weight is not applied
 
[OPTION]
check_only      = NO             # only checking input files (YES/NO)
allow_backup    = NO             # backup existing output files (YES/NO)
convert_type    = PARAMETER      # (REPLICA/PARAMETER)
convert_ids     =                # selected index (empty = all)(example: 1 2 5-10)
num_replicas    = 12             # total number of replicas used in the simulation

nsteps          = 375000000
exchange_period = 2500              # exchange_period in [REMD]
crdout_period   = 2500              # crdout_period in [DYNAMICS]
logout_period   = 2500              # output frequency of logfile
trjout_period   = 2500              # output frequency of trjfile
eneout_period   = 2500              # output frequency of trjfile
trjout_format   = DCD            # (PDB/DCD)
trjout_type     = COOR+BOX       # (COOR/COOR+BOX)
trjout_atom     = 1              # atom group
centering       = NO             # shift center of mass (YES requres psf/prmtop/grotop)
centering_atom  = 1              # atom group
center_coord    = 0.0 0.0 0.0    # target center coordinates
pbc_correct     = NO             # (NO/MOLECULE)
EOF
remd_convert ./remd_convert.inp


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
trjfile1       = run1_par${i}.dcd
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


## MBAR
cat << EOF > mbar_analysis.inp
[INPUT]
cvfile         = run1_par{}.log
 
[OUTPUT]
weightfile     = output/weight{}.dat
 
[MBAR]
nreplica           = 12
dimension          = 1
nblocks            = 1
input_type         = REMD
self_iteration     = 10
temperature        = 300.00 303.48 306.99 310.53 314.10 317.71 321.34 325.01 328.71 332.44 336.22 340.00
target_temperature = 300.0
EOF
mbar_analysis ./mbar_analysis.inp


## Merge
cp /dev/null cv.dat
cp /dev/null weight.dat
for i in {1..12}; do
	cat cv${i}.dat >> cv.dat
	cat weight${i}.dat >> weight.dat
done


## Calc reweighted PMF
./calc_pmf_remd.py -t 300.0 -c 0.0 -n 2000000 --Xmin 0.0 --Xmax 15.0 --Xdel 0.1 --cv_file cv.dat --weight_file weight.dat
