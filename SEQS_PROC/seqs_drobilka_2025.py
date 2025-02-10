#!/usr/bin/python

def Seqs_Drobilka(in_name, out_name, seq_lenz, seq_over):

	print in_name + ' ' + out_name + ' ' + `seq_lenz` + ' ' + `seq_over`

	in_fail  = open(in_name,  "rb")
	out_fail = open(out_name, "wb")
	fasta_id_array = []
	line_counter = 0
	have_seqs = ""
	proper_id = ""
	my_seqs = []

	print 'SubSeqs: ' + `seq_lenz`
	print 'Overlap: ' + `seq_over`

	while 1:
		t = in_fail.readline()
		if t == '':
			###  SUB_SEQ FUNCTION  ###
			chunk_count = 1
			seqs_points = 0
			have_seqs = "".join(my_seqs)
			seqs_len = len(have_seqs)
			while seqs_points <= seqs_len:
				# print `seqs_points` + ' ' + `seq_lenz`
				sub_seqs = have_seqs[seqs_points:(seq_lenz + seqs_points)]
				sub_lenz = len(sub_seqs)
				start_point = seqs_points + 1
				end_point   = seqs_points + seq_lenz
				if end_point > seqs_len:
					end_point = seqs_len
				if (end_point - start_point) >= seq_over and sub_lenz >= seq_lenz:
					out_fail.write('>' + proper_id + '_' + `chunk_count` + ' ' + proper_id + ' [' \
					+ `start_point` + '-' + `end_point` + ' ' + `seq_over` + ' ' + `seqs_len` + '] ' \
					+ good_name + '\n')
					out_fail.write(sub_seqs + '\n')
				chunk_count += 1
				seqs_points += (seq_lenz - seq_over)
			# print seqs_len
			# out_fail.write('>' + proper_id + ' ' + good_name + '\n')
			# out_fail.write(have_seqs + '\n')
			####  END OF SUB_SEQ  ####
			break
		if '\n' in t:
			t = t[:-1]
		if '\r' in t:
			t = t[:-1]

		fasta_match = t[0:1]
		if fasta_match == ">":
			gi_test = t[0:4]
			if gi_test == ">gi|":
				# print gi_test
				descr_line = t
				descr_line = re.sub("^>gi\|", "", descr_line)
				descr_line = re.sub("\|", '\t', descr_line, 1)
				# print line_counter
				line_counter += 1
			else:
				descr_line = t
				descr_line = re.sub("^>", "", descr_line)
				descr_line = re.sub(" ", '\t', descr_line, 1)
				# print line_counter
				line_counter = line_counter + 1
			try:
				good_head = string.split(descr_line, '\t')[0]
				long_tail = string.split(descr_line, '\t')[1]
			except:
				good_head = descr_line
				long_tail = ""
#			if good_head in fasta_id_array:
#				running_text = "\
# \n\n  Ooops... ID duplication  \n\n  check input for duplications  \n\n\n ID: " + good_head + "\n\n\n"
#				print running_text
#				###
#				### INSERT TKINTER TEXT MESSAGE BOX
#				###
#				break
#			fasta_id_array.append(good_head)
			print `line_counter` + '\t' + good_head
			if line_counter != 1:
				###  SUB_SEQ FUNCTION  ###
				chunk_count = 1
				seqs_points = 0
				have_seqs = "".join(my_seqs)
				seqs_len = len(have_seqs)
				while seqs_points <= seqs_len:
					# print `seqs_points` + ' ' + `seq_lenz`
					sub_seqs = have_seqs[seqs_points:(seq_lenz + seqs_points)]
					sub_lenz = len(sub_seqs)
					start_point = seqs_points + 1
					end_point   = seqs_points + seq_lenz
					if end_point > seqs_len:
						end_point = seqs_len
					if (end_point - start_point) >= seq_over and sub_lenz >= seq_lenz:
						out_fail.write('>' + proper_id + '_' + `chunk_count` + ' ' + proper_id + ' [' \
						+ `start_point` + '-' + `end_point` + ' ' + `seq_over` + ' ' + `seqs_len` + '] ' \
						+ good_name + '\n')
						out_fail.write(sub_seqs + '\n')
					chunk_count += 1
					seqs_points += (seq_lenz - seq_over)
				# print seqs_len
				# out_fail.write('>' + proper_id + ' ' + good_name + '\n')
				# out_fail.write(have_seqs + '\n')
				####  END OF SUB_SEQ  ####
			# out_fail.write('>' + good_head + ' ' + `line_counter` + ' ' + long_tail + '\n')
			have_seqs = ""
			my_seqs = []
		if fasta_match != ">" and fasta_match != "":
			proper_id = good_head
			good_name = long_tail
			# have_seqs += t
			my_seqs.append(t)

	in_fail.close()
	out_fail.close()

import math
import re
import sys
import string
if __name__ == "__main__":
	if len(sys.argv) <= 4 or len(sys.argv) > 5:
		print "Program usage: "
		print "input_file output_file seq_length seq_overlap"
		exit
	if len(sys.argv) == 5:
		in_name  = sys.argv[1]
		out_name = sys.argv[2]
		seq_lenz = sys.argv[3]
		seq_over = sys.argv[4]
		seq_lenz = int(seq_lenz)
		seq_over = int(seq_over)
		### if (seq_lenz - seq_over) >= 10:
		if (seq_lenz - seq_over) >= 0:
			Seqs_Drobilka(in_name, out_name, seq_lenz, seq_over)
		else:
			print ""
			print "-------------------------------------------------------------"
			print "Difference Sequence_Length - Sequence_Overlap should be >= 0 "
			print "-------------------------------------------------------------"
			print ""
