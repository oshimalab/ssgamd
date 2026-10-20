# Site-selective Gaussian accelerated Molecular Dynamics (ssGaMD)
ssGaMD selectively enhances molecular motions associated with a specified region or set of interactions.
The method allows selected dihedral, electrostatic, and Lennard–Jones energy terms to be biased independently or in combination,
while limiting direct biasing of the rest of the system.
ssGaMD can be combined with replica-exchange umbrella sampling (ssGaREUS) or temperature replica-exchange molecular dynamics (ssGaREMD)
to further enhance the sampling of association/dissociation processes and conformational changes.
ssGaMD is implemented these methods into GENESIS.
The differences of source codes from GENESIS v2.1.2 are prepared as a patch file.

## Installation
Download GENESIS v2.1.2 from GENESIS GitHub repository and expand it using tar command.
```bash
wget https://github.com/genesis-release-r-ccs/genesis/archive/refs/tags/v2.1.2.tar.gz
tar zxvf v2.1.2.tar.gz
```
Move into the directory of genesis-2.1.2, place diff.patch at the directory, and apply the patch.
```bash
cd genesis-2.1.2
patch -p1 < diff.patch
```
Compile GENESIS
```bash
autoreconf
./configure
make -j4
make install
```

## Simulation Files in ssGaMD paper
This dataset contains molecular structures, topology and coordinate files, simulation input files, and restart files for simulations of beta-cyclodextrin-aspirin binding, Src kinase-PP1 binding, and Trp-cage folding. For each system, scripts for reweighting (reweight.sh) are prepared.

### Directory structure
```bash
data
├── aspirin
│   ├── cmd
│   │   ├── calc_pmf.py
│   │   ├── reweight.sh
│   │   ├── run.inp
│   │   └── run0.rst
│   ├── gamd
│   │   ├── calc_pmf_gamd.py
│   │   ├── reweight.sh
│   │   ├── run.inp
│   │   └── run0.rst
│   ├── ssgamd
│   │   ├── calc_dG.py
│   │   ├── calc_pmf_ssgamd.py
│   │   ├── reweight.sh
│   │   ├── run.inp
│   │   └── run0.rst
│   ├── system.inpcrd
│   ├── system.pdb
│   └── system.prmtop
├── src_pp1
│   ├── reus
│   │   ├── reweight.sh
│   │   ├── rst
│   │   │   ├── rep1.rst
│   │   │   ├── rep10.rst
│   │   │   ├── ...
│   │   │   ├── rep8.rst
│   │   │   └── rep9.rst
│   │   └── run.inp
│   ├── ssgareus
│   │   ├── calc_pmf_ssgamd.py
│   │   ├── reweight.sh
│   │   ├── rst
│   │   │   ├── rep1.rst
│   │   │   ├── rep10.rst
│   │   │   ├── ...
│   │   │   ├── rep8.rst
│   │   │   └── rep9.rst
│   │   └── run.inp
│   ├── system.inpcrd
│   ├── system.pdb
│   └── system.prmtop
└── trpcage
    ├── remd
    │   ├── calc_pmf_remd.py
    │   ├── reweight.sh
    │   ├── run.inp
    │   └── run0.rst
    ├── ssgamd
    │   ├── calc_pmf_ssgamd.py
    │   ├── reweight.sh
    │   ├── run0.rst
    │   ├── run1.inp
    │   ├── run10.inp
    │   ├── ...
    │   ├── run8.inp
    │   └── run9.inp
    ├── ssgaremd
    │   ├── calc_pmf_ssgamd.py
    │   ├── reweight.sh
    │   ├── run.inp
    │   └── run0.rst
    ├── system.inpcrd
    ├── system.pdb
    └── system.prmtop
```
### File descriptions

| Extension | Description |
|---|---|
| `.pdb` | Molecular structure in PDB format. |
| `.prmtop` | AMBER topology file. |
| `.inpcrd` | AMBER coordinate file. |
| `.inp` | GENESIS input file. |
| `.rst` | Restart file for each simulation. |


## Citations
```bibtex
@article{Oshima2026ssGaMD,
  title = {Site-Selective Gaussian Accelerated Molecular Dynamics and Its Integration with Replica-Exchange Methods},
  journal = {ChemRxiv},
  url = {https://chemrxiv.org/doi/full/10.26434/chemrxiv.15010586/v1},
  doi = {10.26434/chemrxiv.15010586/v1},
  author = {Oshima, Hiraku},
}
```
