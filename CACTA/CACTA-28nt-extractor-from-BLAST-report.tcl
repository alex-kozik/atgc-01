#!/usr/bin/tcl

proc Reverse_Complement_String { seq_frw } {
        set string_rev {}
        set i [string length $seq_frw]
        while { $i > 0 } {
            append string_rev [string index $seq_frw [incr i -1]]
        }
        set seq_rev_compl [string map { A T G C C G T A N N } $string_rev]
        return $seq_rev_compl
}

proc Process_Tables {argv} {

    set f_in1  [open [lindex $argv 0] "r"]
    set f_in2  [open [lindex $argv 1] "r"]
    set f_out1 [open [lindex $argv 2] "w"]
    set f_out2 [open [lindex $argv 3] "w"]

    global id_array

    ####### READ DNA SEQUENCES FROM TAB-DELIMITED FILE INTO MEMORY #######
    set l 0
    while { [gets $f_in2 current_line] >= 0 } {
	set current_data [split   $current_line "\t"]
	set prime_id     [lindex  $current_data 0]
	set seqs_len     [lindex  $current_data 1]
	set dna_seqs     [lindex  $current_data 2]
	set id_array($prime_id) $dna_seqs
	incr l
	puts "$prime_id\t***\t$seqs_len\t***\t$l"
    }
    close $f_in2

    ####### READ BLAST ALL HITS TABLE AND EXTRACT 28nt CACTA SEGMENTS #######
    set k 0
    set m 0
    set e 0
    while {[gets $f_in1 current_line] >= 0} {
	set current_data   [split   $current_line "\t"]
	set current_id     [lindex  $current_data  1]
	set q_start        [lindex  $current_data 10]
	set q_end          [lindex  $current_data 11]
	set s_first        [lindex  $current_data 12]
	set s_last         [lindex  $current_data 13]

	### CHECK AND FLIP SUBJECT COORDINATES ###

	set s_start 0
	set s_end   0
	set s_dir   "XXX"

	if {$s_first < $s_last} {
	    set s_start  [ expr $s_first -1 ]
	    set s_end    [ expr $s_last  -1 ]
	    set s_dir    "FRW"
	    set CACTA_01 $s_start
	    set CACTA_28 [ expr $s_start + 28 -1 ]
	    set TDS_1    [ expr $CACTA_01    - 3 ]
	    set TDS_3    [ expr $CACTA_01    - 1 ]
	}
	if {$s_first > $s_last} {
	    set s_start  [ expr $s_last  -1 ]
	    set s_end    [ expr $s_first -1 ]
	    set s_dir    "REV"
	    # set adj      [ expr 28 - ($s_first - $s_last)]
	    # set adj      [ expr 28 - ($s_end - $s_start)]
	    # set CACTA_01 [ expr $s_start - $adj ]
	    # set CACTA_28 [ expr $s_start + 28 -$adj ]
	    set CACTA_28 [ expr $s_end      -0 ]
	    set CACTA_01 [ expr $s_end - 28 +1 ]
	    set TDS_1    [ expr $CACTA_28  + 1 ]
	    set TDS_3    [ expr $CACTA_28  + 3 ]
	}

	set query_id [info exists id_array($current_id)]
	if {$query_id == 0} {
	    puts "  $current_id  WAS NOT FOUND   --- $k * $m LINES  "
	    puts $f_out2 $current_line
	    incr m
	}
	if {$query_id == 1} {
	    puts "  $current_id  WAS   EXTRACTED +++ $k * $e LINES  "
	    set current_seqs $id_array($current_id)
	    set subj_segment  [string range $current_seqs $s_start $s_end]
	    set CACTA_segment [string range $current_seqs $CACTA_01 $CACTA_28]
	    set TDS_segment   [string range $current_seqs $TDS_1 $TDS_3]
	    set CACTA_out     $CACTA_segment
	    set seq_out $subj_segment
	    set TDS_out $TDS_segment
	    if { $s_dir == "REV" } {
	    	set seq_out    [Reverse_Complement_String $subj_segment]
		set CACTA_out  [Reverse_Complement_String $CACTA_segment]
		set TDS_out    [Reverse_Complement_String $TDS_segment]
	    }
	    ### puts $f_out1 "$current_id\t$s_dir\t$subj_segment\t$seq_out\t$CACTA_out"
	    if { $s_dir == "FRW" } {
		puts $f_out1 "$current_id\t$subj_segment\t$seq_out\t$CACTA_01\t$s_dir\t\*$TDS_segment\*\t$TDS_out\t$CACTA_out\t***\t$TDS_segment\*$CACTA_segment\t$TDS_1\t$TDS_3\t$CACTA_01\t$CACTA_28"
	    }
            if { $s_dir == "REV" } {
                puts $f_out1 "$current_id\t$subj_segment\t$seq_out\t$CACTA_28\t$s_dir\t\*$TDS_segment\*\t$TDS_out\t$CACTA_out\t***\t$CACTA_segment\*$TDS_segment\t$CACTA_01\t$CACTA_28\t$TDS_1\t$TDS_3"
            }
	    incr e
	}
	incr k
    }

    puts "$m DATAPOINT OUT OF $k WERE NOT EXTRACTED"
    puts "$e DATAPOINT OUT OF $k WERE     EXTRACTED"

    close $f_in1
    close $f_out1
    close $f_out2
    puts ""
    puts "DONE"
}

if {$argc != 4} {
    puts "Program usage:"
    puts "Blast_All_Hits_Table, Seqs_List, output_file1, output_file2"
} else {
    Process_Tables $argv
}
