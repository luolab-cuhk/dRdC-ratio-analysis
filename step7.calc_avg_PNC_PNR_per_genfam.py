#!/usr/bin/env python

# This script calcuate the PNC and PNR values of ControlClade v.s. RefClade and TargetClade v.s. RefClade
# usage:   $ ./calc* <classification charge|MY> <clade file> <outfile>
# example: $ ./calc* charge genome_and_clades.txt PNC_PNR.txt
# note:    1) The clade file should specify one of the following three clades in the second column: TargetClade, ControlClade and RefClade
#           2) In the HON output, "Proportions of radical differences" means dR, that is, the number of radical changes per radical site.
#              Similarly, "Proportions of conservative differences" means dC, that is, the number of conservative changes per conservative site.
#               Conceptually, dR = [num of radical changes between seq1 and seq2] / (([num_rad_sites in seq1] + [num_rad_sites in seq2])/2) 
#               and dC = [num of conservative changes between seq1 and seq2] / (([num_con_sites in seq1] + [num_con_sites in seq2])/2) 


import os
import sys

# =================
# class
# =================

class Gene():
    list = []

    def __init__(self, name, ctl_cnt, tgt_cnt, ref_cnt, target_dC, target_dR, control_dC, control_dR):

        self.name = name
        self.target_dC = target_dC
        self.target_dR = target_dR
        self.control_dC = control_dC
        self.control_dR = control_dR
        self.target_cnt = tgt_cnt        # number of target genomes in the *.SEQ file of the genfam
        self.control_cnt = ctl_cnt        # number of control genomes in the *.SEQ file of the genfam
        self.ref_cnt = ref_cnt            # number of ref genomes in the *.SEQ file of the genfam

        self.target_dRdC = target_dR / target_dC
        self.control_dRdC = control_dR / control_dC
        self.sstr = "%s\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%d\t%d\t%d\n" % (name, \
                target_dR, target_dC, self.target_dRdC, \
                control_dR, control_dC, self.control_dRdC, \
                tgt_cnt, ctl_cnt, ref_cnt)
        

# =================
# functions
# =================

# load seq id from *.SEQ file, that is the input of HON program
def load_seq_id(ddict, seqfile, dict_clades):
    ctl_cnt = 0
    tgt_cnt = 0
    ref_cnt = 0
    with open(seqfile) as f:
        f.readline()
        line = f.readline()
        i = 0
        while line:
#xiaoyuan
            name = line[:-1].split("|")[0]
#end
            ddict[i] = name
            if name in dict_clades:
                if dict_clades[name]=="ControlClade":        
                    ctl_cnt += 1
                elif dict_clades[name]=="TargetClade":        
                    tgt_cnt += 1
                elif dict_clades[name]=="RefClade":        
                    ref_cnt += 1
            f.readline()
            line = f.readline()
            i += 1
    return [ctl_cnt, tgt_cnt, ref_cnt]

# load dR or dC values for the matrix of HON output
def load_dR_or_dC(ffile, header_str, ddict):
    with open(ffile) as f:
        line = f.readline()
        while line:
            if line.startswith(header_str):
                line = f.readline()
                i = 0
                while line and not line.startswith("\n"):
                    arr = line[3:-2].split()
                    for j in range(i+1, len(arr)):
                        # discard dR or dC that has nan value :::::::: FILTER 2 ::::::::
                        if not "nan" in arr[j]:
                            ind = "%d_%d" % (i, j)
                            ddict[ind] = float(arr[j])
                    line = f.readline()
                    i += 1
            line = f.readline()

def average(llist):
    return sum(llist)/len(llist)


# ===============================
# MAIN
# ===============================

if __name__ == "__main__" :

    classifi = sys.argv[1]
    cladefile = sys.argv[2]
    outfile = sys.argv[3]

    # ========================
    # load genome and clades
    # ========================
    dict_clades = {} # indexed by genome name, pointed to clade name
    with open(cladefile) as f:
        line = f.readline()
        while line:
            arr = line.rstrip().split("\t")
            dict_clades[arr[0]] = arr[1]
            line = f.readline()

    # =================================
    # load dRdC data of each genfamily
    # =================================
    # get list of HON output file
    list_datfiles = []
    os.system("ls pt*/*.%s_out > ls.tmp" % classifi)
    with open("ls.tmp") as f:
        line = f.readline()
        while line:
            list_datfiles.append(line[:-1])
            line = f.readline()
#    os.system("rm ls.tmp")

    # for each gene family, load the HON output
    dict_genfam = {} # indexed by genfam id, pointed to Gene object
    for datfile in list_datfiles:
        genfam = datfile.split("/")[-1].split(".")[0]

        # 1) load genome id from *.SEQ file and check if there is enough genome for dRdC analysis
        dict_genome = {} # indexed by 0,1,2,3 (the order in *.SEQ) and pointed to genome name
        seqfile = "../../03_tstv/%s.seq" % genfam    
        [ctl_cnt, tgt_cnt, ref_cnt] = load_seq_id(dict_genome, seqfile, dict_clades)
        # check if this genfam has enough data for dRdC analysis :::::::: FILTER 1 ::::::::
#xiaoyuan modified here
        if (ctl_cnt<1 or tgt_cnt<1 or ref_cnt<1):
#        if (ctl_cnt<2 or tgt_cnt<2 or ref_cnt<2):
#end of modification
            continue # skip this genfam if not enough genome

        # 2) make another clade dict that is indexed by genome id
        dict_clades2 = {}
        for id, genome in dict_genome.items():
            if genome in dict_clades:
                dict_clades2[id] = dict_clades[genome]
            else:
                dict_clades2[id] = "NA"

              # 3) load dR and dC from matrix of "Proportions of radical differences" and "Proportions of conservative differences"
        dict_dR = {} # indexed by "%s_%s" % (genome1_index, genome2_index) and pointed to its dR value
        dict_dC = {} # indexed by "%s_%s" % (genome1_index, genome2_index) and pointed to its dC value
        load_dR_or_dC(datfile, "Proportions of radical differences", dict_dR)
        load_dR_or_dC(datfile, "Proportions of conservative differences", dict_dC)

        # 4) add dR and dC to list
        # 4-1) get list of ind that both dR and dC values are available :::::::: FILTER 2 ::::::::
        paired = [] # list ind that have both dR and dC available
        for ind,dR in dict_dR.items():
            # only use dR and dC values
            if ind in dict_dC:
                paired.append(ind)
        # 4-2) assign the paired dR dC to the ls_target or ls_control
        ls_target_dC = []
        ls_target_dR = []
        ls_control_dC = []
        ls_control_dR = []
        for ind in paired:
            # get clades that are involved in this dR and dC
            arr = ind.split("_")
            [clade_i, clade_j] = [ dict_clades2[int(arr[0])], dict_clades2[int(arr[1])] ]
            # target_vs_ref: one seq from target clade and the other from ref clade
            if "TargetClade" in [clade_i, clade_j] and "RefClade" in [clade_i, clade_j]:
                dR = dict_dR[ind]
                dC = dict_dC[ind]
                ls_target_dR.append(dR)
                ls_target_dC.append(dC)
            # control_vs_ref: one seq from control clade and the other from ref clade
            elif "ControlClade" in [clade_i, clade_j] and "RefClade" in [clade_i, clade_j]:
                dR = dict_dR[ind]
                dC = dict_dC[ind]
                ls_control_dR.append(dR)
                ls_control_dC.append(dC)
#add filter modification, next if target_dC * control_dC == 0
        if (len(ls_target_dC) * len(ls_control_dC) * len(ls_target_dR) * len(ls_control_dR)) == 0:
            continue
        if (sum(ls_target_dC) * sum(ls_control_dC) * sum(ls_target_dR) * sum(ls_control_dR)) == 0:
            continue
#end of modification
        # 4-3) only when the number of available dR and dC reach a certain amount will be used :::::::: FILTER 3 ::::::::
#xiaoyuan modified here
        if len(ls_target_dR) > tgt_cnt*ref_cnt/3  and  len(ls_control_dC) > ctl_cnt*ref_cnt/3:
#end of modification
            dict_genfam[genfam] = Gene(genfam, ctl_cnt, tgt_cnt, ref_cnt, average(ls_target_dC), average(ls_target_dR), average(ls_control_dC), average(ls_control_dR))
            Gene.list.append(genfam)

    # ==============================
    # write to file
    # ==============================
    with open(outfile, "w") as f:
        f.write("family\tPNR_target\tPNC_target\tratio_target\tPNR_control\tPNC_control\tratio_control\tcount_target\tcount_control\tcount_ref\n")
        for datfile in list_datfiles:
            genfam = datfile.split("/")[-1].split(".")[0]
            if genfam in dict_genfam:
                f.write(dict_genfam[genfam].sstr)



    

