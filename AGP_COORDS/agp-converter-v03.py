#!/usr/bin/python
######################################################################################
#
# Authors:
#          Alexander Kozik (akozik@atgc.org)
#          Huaqin Xu (huaxu@ucdavis.edu)
#
# Project start:  Mar 7 2020
# Major revision: Sep 7 2021
# Description:
#
# This python script update coordinates in genomic agp file according to scaffold coordinates and strand.
#
# =================================================================================
# Input file:
# genomic agp1 (contigs), agp2 (super-scaffolds)
# ---------------------------------------------------------------------------------
# Output file format:
# updated genomic agp file
#
######################################################################################

import sys
import re

# ---------------------------functions ------------------------------------------------
# -------------------------------------------------------------------------------------

def open_file(file_name, mode):
	try:
		the_file = open(file_name, mode)
	except(IOError), e:
		print "Unable to open the file", file_name, "Ending program.\n", e
		raw_input("\n\nPress the enter key to exit.")
		sys.exit()
	else:
		return the_file

def read_file(afile):
        try:
                flines = afile.readlines()
        except:
                print 'Failed to read from: ', afile
                sys.exit(0)
        else:
                return flines

#----------------------------- main -------------------------------------------------
# ----- get input file names and construct output file name and open files ----------

if len(sys.argv) == 4:
        agpCFile=sys.argv[1]
        agpSFile=sys.argv[2]
        outName=sys.argv[3]
else:
        print len(sys.argv)
        print 'Usage: [1]input AGP1 file (Contigs), [2]input AGP2 file (Super-Scaffolds), [3]output AGP file'
        sys.exit(1)

outFile= outName + '.xcoordsx.tab'
logFile= outName + '.unplaced.tab'

agpCF=open_file(agpCFile,'r')
agpSF=open_file(agpSFile,'r')
outF=open_file(outFile,'w')
logF=open_file(logFile,'w')

agpClines = read_file(agpCF)
agpSlines = read_file(agpSF)

linecount = len(agpClines)
chrom={}
strand={}
coordsA = {}
coordsB = {}
entity = {}
skipline=0
outcount=0
start = 0
end = 0
nstrand = '+'

### read scaffold agp file ###
for y in agpSlines:
	yline = y.rstrip().split('\t')
	if yline[4] == 'W':
		scaffold = yline[5]
		entity[scaffold] = scaffold
		chrom[scaffold]=yline[0]
		strand[scaffold]=yline[8]
		coordsA[scaffold]=int(yline[1])
		coordsB[scaffold]=int(yline[2])

### read contig agp file ###
for i in agpClines:
	aline = i.rstrip().split('\t')
	if len(aline) == 9:
		if aline[0] not in chrom:
			logF.write('\t'.join(aline)+'\n')
			skipline +=1
		else:
			if aline[4] == 'W':

				if strand[aline[0]] == '+':
					start = coordsA[aline[0]] + int(aline[1]) -1
					end   = coordsA[aline[0]] + int(aline[2]) -1
					nstrand = aline[8]
				else:
					start = coordsB[aline[0]] - int(aline[2]) +1
					end   = coordsB[aline[0]] - int(aline[1]) +1
					if aline[8] == '+':
						nstrand = '-'
					else:
						nstrand = '+'
				### OUTPUT TABLE CONTIGS ###
				### CHROMOSOME AND SCAFFOLD IDs ###
				outF.write(chrom[aline[0]] + '\t' + aline[0] + \
						### COORDINATES OLD AND NEW ###
						'\t' + aline[1] + '\t' + aline[2] + '\t' + str(start) + '\t' + str(end) + \
						### ITEM COUNT (MUST BE POST-PROCESSED IN EXCEL) ###
						'\t' + aline[3] + \
						### W ###
						'\t' + aline[4] + \
						### CONTIG ID ###
						'\t' + aline[5] + \
						### CONTIG START-END LENGTH ###
						'\t' + aline[6] + '\t' + aline[7] + \
						### STRAND OLD AND NEW WITH SUPER-SCAFFOLD INFO ###
						'\t' + aline[8] + '\t' + nstrand + '\t' + strand[aline[0]] + '\n')
			if aline[4] == 'N':
				if strand[aline[0]] == '+':
                                        start = coordsA[aline[0]] + int(aline[1]) -1
                                        end   = coordsA[aline[0]] + int(aline[2]) -1
                                        nstrand = aline[8]
                                else:
                                        start = coordsB[aline[0]] - int(aline[2]) +1
                                        end   = coordsB[aline[0]] - int(aline[1]) +1

                                ### OUTPUT TABLE GAPS ###
				### CHROMOSOME AND SCAFFOLD IDs ###
                                outF.write(chrom[aline[0]] + '\t' + aline[0] + \
                                                ### COORDINATES OLD AND NEW ###
                                                '\t' + aline[1] + '\t' + aline[2] + '\t' + str(start) + '\t' + str(end) + \
                                                ### ITEM COUNT (MUST BE POST-PROCESSED IN EXCEL) ###
                                                '\t' + aline[3] + \
                                                ### N ###
                                                '\t' + aline[4] + \
                                                ### GAP LENGTH ###
                                                '\t' + aline[5] + \
                                                ### GAP TYPE (SCAFFOLD)  ###
                                                '\t' + aline[6] + \
						### EVIDENCE ###
						'\t' + aline[7] + \
                                                ### EVIDENCE TYPE ###
                                                '\t' + 'X' + '\t' + aline[8] + '\t' + 'X' + '\n')

			outcount+=1

	else:
		outF.write('\t'.join(aline)+'\n')
		skipline +=1

agpCF.close()
agpSF.close()

print 'Processing ... ...'
print '...... Read %s lines, skip %s lines' %(linecount, skipline)
print '...... Write Output %s lines' %(outcount)
print 'Please find output in file %s' %(outFile)

outF.close()
logF.close()
