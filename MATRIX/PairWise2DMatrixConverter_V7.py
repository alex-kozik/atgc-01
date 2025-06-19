#!/usr/bin/python

#################################################################
#                                                               #
#                   PIRWISE 2D MATRIX CONVERTER                 #
#                                                               #
#                                                               #
#            EDITS  2005  2006  2007  2008  2009  2025          #
#                        Alexander Kozik                        #
#                                                               #
#                      http://www.atgc.org/                     #
#                                                               #
#                                                               #
#                                                               #
#################################################################

def Read_Data_File(in_name1, in_name2, out_name, check_map):

	global add_on_values
	global default_diff
	global dummy_debug
	global round_scale
	global pwd_matrix_column

	global out_file1
	global out_file2

	print "                                             "
	print "============================================="
	print " MATRIX (ALL PAIRS) :  " + in_name1
	print " MATRIX COLUMN      :  " + str(pwd_matrix_column)
	print " MARKERS  TO  MAP   :  " + in_name2
	print " WHAT TODO WITH LIST:  " + check_map
	print "============================================="
	print "                                             "

	time.sleep(2)

	in_file1  = open(in_name1,  "rb")
	in_file2  = open(in_name2,  "rb")
	out_file1 = open(out_name + '.matrix_2D.tab', "wb")
	out_file2 = open(out_name + '.matrix_PW.tab', "wb")

	global id_list
	global id_array
	global matrix_array
	global map_order
	global map_array
	global nrl_array

	id_list   = []		; # LIST OF ALL NON-REDUNDANT IDs
	id_array  = {}		; # ARRAY OF IDs ( -1 IS NOT MAPPED   +1 IS MAPPED )
	matrix_array = {}	; # DISTANCE PAIRWISE DATA FOR MARKERS
	map_order    = []	; # CURRENT MAP BEST ORDER
	delta_array  = {}	; # ARRAY OF CURRENT DELTA-DIFF
	map_array    = {}	; # ARRAY OF CURRENT ALL ORDERS
	nrl_array    = {}	; # ARRAY OF NON-REDUNDANT MAPS (REVERSE CASE IS CONSIDERED)

	#####################################################
	print "READ MARKERS TO MAP LIST"
	time.sleep(2)
	n = 0
	while 1:
		t = in_file2.readline()
		if t == '':
			break
		if '\n' in t:
			t = t[:-1]
		if '\r' in t:
			t = t[:-1]
		tl = t.split('\t')
		####

		marker = tl[0]

		if marker in id_list:
			print ""
			print " MARKER ID DUPLICATION:   " + marker
			print ""
			sys.exit()

		if marker not in id_list:
			id_list.append(marker)
			n = n + 1
			print `n` + '\t' + marker

	print ""
	print "============================================="
	print `n` + " IDs FOUND IN MARKER LIST "
	print "============================================="
	print ""

	time.sleep(2)

	print ""
	print "============================================="
	print id_list
	print "============================================="
	print "LENGTH:  " + `len(id_list)`
	print "============================================="
	print ""

	time.sleep(2)

	#####################################################

	print "  READ MATRIX FILE  "
	time.sleep(2)
	k = 0
	while 1:
		t = in_file1.readline()
		if t == '':
			break
		if '\n' in t:
			t = t[:-1]
		if '\r' in t:
			t = t[:-1]
		tl = t.split('\t')
		####
		value0    = tl[1]		; # ID1
		value1    = tl[2]		; # ID2
		value2    = float(tl[pwd_matrix_column])	; # MATRIX VALUES
		print value0 + '\t' + value1 + '\t' + `value2`
		if value0 in id_list and value1 in id_list:
			matrix_array[value0,value1] = value2
			sys.stdout.write(`k` + " ")
			k = k + 1

	print ""
	print "============================================="

	if k > 0:
		print ""
		print `k` + " PAIRS FOUND IN MATRIX"
		print ""
		time.sleep(2)
	else:
		print ""
		print "NO DATA IN MATRIX FILE"
		print "NOTHING TO DO ....  EXIT"
		print "TERMINATED"
		print "============================================="
		print ""
		sys.exit()

	print "========================================"
	print "         TWO DIMENSIONAL MATRIX         "
	print "========================================"

	time.sleep(2)

	### TWO DIMENSIONAL MATRIX ###

	out_file1.write(";" + '\t')

	best_map = id_list
	mega_length = len(best_map)

	### FIRST ROW ###
	counter = 0
	for item in best_map:
		current_id = item
		out_file1.write(current_id)
		counter = counter + 1
		if counter < mega_length:
			out_file1.write('\t')
		if counter == mega_length:
			out_file1.write('\n')

	### PAIRWISE DATA ROWS ###
	for item in best_map:
		current_id = item
		out_file1.write(current_id + '\t')
		counter = 0
		for other_item in best_map:
			counter = counter + 1
			other_id = other_item
			try:
				cur_diff1 = float(matrix_array[current_id,other_id])
			except:
				cur_diff1 = 0
			if add_on_values == "TRUE":
				try:
					cur_diff2 = float(matrix_array[other_id,current_id])
				except:
					cur_diff2 = 0
			if add_on_values == "FALSE":
				cur_diff2 = 0
			cur_diff = cur_diff1 + cur_diff2
			# cur_diff_string = str(round(cur_diff,round_scale))
			cur_diff_string = str(int(cur_diff))
			cur_value = cur_diff_string
			out_file1.write(cur_value)
			out_file2.write(item + '\t' + other_item + '\t' + cur_value + '\n')
			if counter < mega_length:
				out_file1.write('\t')
			if counter == mega_length:
				out_file1.write('\n')


	print "                         "
	print "     .. WELL DONE ..     "
	print "     ENJOY  ANALYSIS     "
	print "                         "

	### THE  END ###
	in_file1.close()
	in_file2.close()
	out_file1.close()
	out_file2.close()
	################

### MAIN BODY ###

import math
import re
import sys
import string
import time

global add_on_values
add_on_values = "TRUE"
# add_on_values = "FALSE"

global round_scale
round_scale = 2

### COLUMN WITH PW VALUES ###
### COUNT FROM 0 : 2 == 3 ###
global pwd_matrix_column
# pwd_matrix_column = 2
pwd_matrix_column = 0
default_diff = 0

### TO CHECK OR NOT TO CHECK FRAME ORDER ###
fixed_frame = "FALSE"
# fixed_frame = "TRUE"

dummy_debug = "FALSE"
# dummy_debug = "TRUE"

check_map = "FALSE"

if __name__ == "__main__":
	if len(sys.argv) <= 4 or len(sys.argv) >= 6:
		print "                                                                "
		print " Program usage:                                                 "
		print " [matrix(all_pairs)] [items_to_order] [output_file] [CHECK_MAP] "
		print "                                                                "
		exit
	if len(sys.argv) == 5:
		in_name1 = sys.argv[1]
		in_name2 = sys.argv[2]
		out_name = sys.argv[3]
		fix_frm  = sys.argv[4]

		if fix_frm == "CHECK_MAP":
			check_map = "TRUE"
		if fix_frm != "CHECK_MAP":
			sys.exit()

		Read_Data_File(in_name1, in_name2, out_name, check_map)

#### THE END ####

