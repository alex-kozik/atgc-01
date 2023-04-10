#!/usr/bin/tcl

proc Process_Tables { argv } {

    set f_in1 [open [lindex $argv 0] "r"]
    set f_out [open [lindex $argv 1] "w"]

    set subj_column [lindex $argv 2]
    set coord1_clmn [lindex $argv 3]
    set coord2_clmn [lindex $argv 4]

    set off_index   [lindex $argv 5]

    set gff_clmn2   [lindex $argv 6]
    set gff_clmn3   [lindex $argv 7]

    set dummy_test  [lindex $argv 8]

    if { $dummy_test != "GFF" } {
	puts " ========================= "
	puts " DID NOT PASS CLARITY TEST "
	puts " LAST OPTION SHOULD BE GFF "
	puts " ========================= "
	exit
    }

    ####### READ BLAST ALL_HITS TABLE AND CONVERT TO GFF #######
    set l 0
    set blank_line_counter 0
    set comment_line_counter 0
    set direction "MOOBA"
    
    while { [gets $f_in1 current_line] >= 0 } {
    	if {$tab_data == "TRUE"} {
		set current_data [split   $current_line           "\t"]
		set subj_id      [lindex  $current_data   $subj_column]
		set coord1       [lindex  $current_data   $coord1_clmn]
		set coord2       [lindex  $current_data   $coord2_clmn]

		set coord1       [expr  $coord1 - $off_index]
		set coord2       [expr  $coord2 - $off_index]

		set direction "BOOBA"

		if {$coord1 < $coord2} {
			set direction "+"
			set segment_len [expr $coord2 - $coord1 + 1]
			puts $f_out "$subj_id\t$gff_clmn2\t$gff_clmn3\t$coord1\t$coord2\t\.\t$direction\t\.\tName=$gff_clmn3;Length\=$segment_len"
		}
		if {$coord1 > $coord2} {
			set direction "-"
			set segment_len [expr $coord1 - $coord2 + 1]
			puts $f_out "$subj_id\t$gff_clmn2\t$gff_clmn3\t$coord2\t$coord1\t\.\t$direction\t\.\tName=$gff_clmn3;Length\=$segment_len"
		}
		if {$coord1 == $coord2} {
			set direction "_NULL_"
			puts        "      $direction         "
			puts        " + TOO GOOD TO BE TRUE + "
			puts $f_out " + TOO GOOD TO BE TRUE + "
			exit
		}
		incr l
	    }
    }
    close $f_in1
    close $f_out

    puts "====================================="
    puts " BLAST DATA    $l lines "
    puts " COMMENT LINES $comment_line_counter "
    puts " BLANK LINES   $blank_line_counter   "
    puts " =================================== "
    puts "               DONE                  "
    puts " =================================== "

    puts "=========="
    puts " $l lines "
    puts " ======== "
    puts "   DONE   "
    puts " ======== "
}

if { $argc != 9 } {
    puts "Program usage:"
    puts "file_to_process, output_file, subj_column(1), coord1(12), coord2(13), off_index(0), gff_column2, gff_column3, GFF"
} else {
    Process_Tables $argv
}
