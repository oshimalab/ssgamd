#!/usr/bin/env python

import numpy as np

temperature = 300.0
RT_kcal = 8.314 * temperature / 4.184 / 1000.0

# Grid for X direction
x_min = 0.0
x_max = 60.0
ngrid_x = 300
delta_x = (x_max - x_min) / ngrid_x

# Initialization of population
population = np.zeros((ngrid_x), float)

# Count configuration on each grid from simulation data
for line in open("cv.dat"):
    a = line.split()
    dist = float(a[1])
    idx_x = int((dist - x_min) / delta_x)
    population[idx_x] += 1.0

# Normalization
population = population / population.sum()

# Calculation of free-energy landscape from population
pmf = -RT_kcal * np.log(population)
pmf = pmf - pmf.min()

## Output free energy on each grid
f = open("pmf.dat", "w")
for i in range(ngrid_x):
    f.write("%f %f\n" % (x_min + (i+0.5)*delta_x, pmf[i]))
f.close()
