#!/usr/bin/env python

import sys, math, os
import numpy as np
import argparse

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--temperature', dest='temperature', default='300', help='temperature')
    parser.add_argument('-c', '--cutoff', dest='cutoff', default='10.0', help='Lower limit of #samples in bins')
    parser.add_argument('-n', '--nsample', dest='nsample', required=True, help='number of samples')
    parser.add_argument('--Xmin', dest='min1', required=True, help='Minimum of x grid')
    parser.add_argument('--Xmax', dest='max1', required=True, help='Maximum of x grid')
    parser.add_argument('--Xdel', dest='delta1', required=True, help='Width of x grid')
    parser.add_argument('--cv_file', dest='cv_file', required=True, help='name of file containing CV')
    parser.add_argument('--out_file', dest='out_file', required=True, help='name of GENESIS output file')
    parser.add_argument('--weight_file', dest='weight_file', default='', help='name of MBAR weight file')
    parser.add_argument('--noreweight', action='store_const', const=True, default=False, help='Reweight or not')
    parser.add_argument('--Xcyclic', action='store_const', const=True, default=False, help='x grid is cyclic or not')
    args = parser.parse_args()

    temperature = float(args.temperature)
    cutoff = float(args.cutoff)
    nsample = int(args.nsample)
    min1 = float(args.min1)
    max1 = float(args.max1)
    delta1 = float(args.delta1)
    out_file = args.out_file
    cv_file = args.cv_file
    weight_file = args.weight_file
    noreweight_flag = args.noreweight
    xcyclic_flag = args.Xcyclic

    nbin_max = 1000000
    fe_max = 10000000.0
    num1 = int((max1-min1) / delta1)
    RT = 8.314 * temperature / 1000.0
    RT_kcal = 8.314 * temperature / 4.184 / 1000.0
    beta = (1000.0 * 4.184) / (8.314 * temperature)

    ## Get boost potentials
    boosts = np.zeros([nsample], float)
    id_dih = -1
    id_lj = -1
    id_elec = -1
    j = 0
    for line in open(out_file):
        if line.startswith("INFO"):
            a = line.split()
            if a[1] == "STEP":
                for i in range(len(a)):
                    if a[i] == "DIH_SGAMD":
                        id_dih = i
                    if a[i] == "LJ_SGAMD":
                        id_lj = i
                    if a[i] == "ELEC_SGAMD":
                        id_elec = i
            elif a[1].isdigit():
                out_step = int(a[1])
                ene_dih = 0.0
                if id_dih >= 0:
                    ene_dih = float(a[id_dih])
                ene_lj = 0.0
                if id_lj >= 0:
                    ene_lj = float(a[id_lj])
                ene_elec = 0.0
                if id_elec >= 0:
                    ene_elec = float(a[id_elec])
                boosts[j] = ene_dih + ene_lj + ene_elec
                j += 1

    ## Get MBAR weight
    weights = np.ones([nsample], float)
    if weight_file != '':
        j = 0
        for line in open(weight_file):
            a = line.split()
            weights[j] = float(a[1])
            j += 1
 
    ## Calculate number of samples and averages in each bin.
    nsample_in_bin = np.zeros([num1], int)
    weights_in_bin = np.zeros([num1], float)
    ave = np.zeros([num1], float)
    ave2 = np.zeros([num1], float)
    j = 0
    for line in open(cv_file):
        a = line.split()
        cv1 = float(a[1])
        idx1 = int((cv1 - min1)/delta1)
        if xcyclic_flag:
            if idx1 >= num1:
                idx1 -= num1
        else:
            if idx1 < num1:
                nsample_in_bin[idx1] += 1
                weights_in_bin[idx1] += weights[j]
                ave[idx1]  += weights[j]*boosts[j]
                ave2[idx1] += weights[j]*boosts[j]**2
                j += 1

    ## Calculate the free energy in each bin
    fe = np.zeros([num1], float)
    fe_noreweight = np.zeros([num1], float)
    fe_min = fe_max
    for i in range(num1):
        if nsample_in_bin[i] == 0:
            fe[i] = fe_max
        else:
            if nsample_in_bin[i] > cutoff:
                c1 = beta*ave[i]/weights_in_bin[i]
                c2 = 0.5*beta**2*(ave2[i]/weights_in_bin[i] - (ave[i]/weights_in_bin[i])**2)
                fe_noreweight[i] = - RT_kcal * np.log(weights_in_bin[i])
                if noreweight_flag:
                    fe[i] = fe_noreweight[i]
                else:
                    fe[i] = - RT_kcal * (c1+c2) + fe_noreweight[i]
        if fe[i] < fe_min:
            fe_min = fe[i]
    fe -= fe_min

    f = open("pmf_1d.dat", "w")
    for i in range(num1):
        f.write("%f %f\n" % (min1+i*delta1+0.5*delta1, fe[i]))
    f.close()
