#!/bin/bash

## Sort
cat << EOF > remd_convert.inp
[INPUT]
prmtopfile = ../system.prmtop
ambcrdfile = ../system.inpcrd
remfile    = ../run1_rep{}.rem     # REMD parameter ID file
dcdfile    = ../run1_rep{}.dcd     # DCD file
logfile    = ../run1_rep{}.log     # REMD energy log file
 
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
num_replicas    = 30             # total number of replicas used in the simulation

nsteps          = 250000000
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

## COM distance
for i in {1..30}; do
cat << EOF > trj_analysis.inp
[INPUT]
prmtopfile     = ../system.prmtop
ambcrdfile     = ../system.inpcrd
 
[OUTPUT]
comdisfile = cv${i}.dat 
 
[TRAJECTORY]
trjfile1       = run1_par${i}.dcd
mdout_period1  = 1
ana_period1    = 1
trj_format     = DCD
trj_type       = COOR
trj_natom      = 0

[SELECTION]
group1 = rnam:PP1 and not hydrogen
group2 = (rno:35 or rno:135) and backbone and not hydrogen and not rnam:WAT

[OPTION]
check_only     = NO
com_distance1 = 1 2
EOF
trj_analysis ./trj_analysis.inp
done

## MBAR
cat << EOF > mbar_analysis.inp
[INPUT]
cvfile         = cv{}.dat
 
[OUTPUT]
weightfile     = weight{}.dat
pmffile        = pmf.dat
  
[MBAR]
nreplica         = 30
dimension        = 1
nblocks          = 1
input_type       = US  # US REMD FEP REST MBGO
self_iteration   = 10
temperature      = 310.0
target_temperature = 310.0
rest_function1   = 1
grids1           = 0.0 24.0 241
output_unit      = kcal/mol

[RESTRAINTS]
constant1  = 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0  2.0
reference1 = 3.0 3.6 4.2 4.8 5.4 6.0 6.6 7.2 7.8 8.4 9.0 9.6 10.2 10.8 11.4 12.0 12.6 13.2 13.8 14.4 15.0 15.6 16.2 16.8 17.4 18.0 18.6 19.2 19.8 20.4
EOF
mbar_analysis ./mbar_analysis
