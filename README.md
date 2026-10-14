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
