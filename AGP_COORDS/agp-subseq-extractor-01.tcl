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

    ####### READ SEQUENCES INTO MEMORY #######
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

    ####### READ AGP COORDS TO PROCESS #######
    set k 0
    set m 0
    set e 0
    while {[gets $f_in1 current_line] >= 0} {
	set current_data  [split   $current_line "\t"]

	set current_id    [lindex  $current_data  0]
	set s_start       [lindex  $current_data  1]
	set s_end         [lindex  $current_data  2]
	set s_part        [lindex  $current_data  3]
	set s_type        [lindex  $current_data  4]
	set s_comp        [lindex  $current_data  5]
	set s_dir         [lindex  $current_data  8]

	### ZERO INDEXING COORDINATES
	set s_start  [ expr $s_start -1 ]
	set s_end    [ expr $s_end   -1 ]

	### SUBSEQUENCE EXTRACTION
	set query_id [info exists id_array($current_id)]
	if {$query_id == 0} {
	    puts "  $current_id  WAS NOT FOUND   --- $k * $m LINES  "
	    puts $f_out2 $current_line
	    incr m
	}
	if {$query_id == 1} {
	    puts "  $current_id  WAS   EXTRACTED +++ $k * $e LINES  "
	    set current_seqs  $id_array($current_id)
	    set seqs_segment  [string range $current_seqs $s_start $s_end]
	    if {$s_dir == "-"} {
		set seqs_segment  [Reverse_Complement_String $seqs_segment]
	    }
	    set seqs_len [string length $seqs_segment]
	    ### WRITE DATA TO OUTPUT FILE
	    puts $f_out1 "$current_id\t$s_part\t$s_start\t$s_end\t$s_type\t\[$s_dir\]\t$s_comp\t$seqs_len\t$seqs_segment"
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
    puts "AGP_Table, Seqs_List, output_file1, output_file2"
} else {
    Process_Tables $argv
}
