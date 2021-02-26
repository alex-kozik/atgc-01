#!/usr/bin/tcl

proc Process_Tables { argv } {

    set f_in1 [open [lindex $argv 0] "r"]
    set f_out [open [lindex $argv 1] "w"]

    set subj_column [lindex $argv 2]
    set coord1_clmn [lindex $argv 3]
    set coord2_clmn [lindex $argv 4]

    set off_index   [lindex $argv 5]

    set dummy_test  [lindex $argv 6]

    puts " Subject:$subj_column C1:$coord1_clmn C2:$coord2_clmn Off_Index:$off_index"

    if { $dummy_test != "BED" } {
	puts " ========================= "
	puts " DID NOT PASS SOBERTY TEST "
	puts " LAST OPTION SHOULD BE BED "
	puts " ========================= "
	exit
    }

    ####### READ BLAST ALL_HITS TABLE AND CONVERT TO BED #######
    set l 0
    while { [gets $f_in1 current_line] >= 0 } {
	set current_data [split   $current_line           "\t"]
	set subj_id      [lindex  $current_data   $subj_column]
	set coord1       [lindex  $current_data   $coord1_clmn]
	set coord2       [lindex  $current_data   $coord2_clmn]

	set coord1       [expr  $coord1 - $off_index]
	set coord2       [expr  $coord2 - $off_index]

	if {$coord1 < $coord2} {
		puts $f_out "$subj_id\t$coord1\t$coord2"
	}
        if {$coord1 > $coord2} {
                puts $f_out "$subj_id\t$coord2\t$coord1"
        }
        if {$coord1 == $coord2} {
		puts        " + TOO GOOD TO BE TRUE + "
                puts $f_out " + TOO GOOD TO BE TRUE + "
		exit
        }
	incr l
    }
    close $f_in1
    close $f_out

    puts "=========="
    puts " $l lines "
    puts " ======== "
    puts "   DONE   "
    puts " ======== "
}

if { $argc != 7 } {
    puts "Program usage:"
    puts "file_to_process, output_file, subj_column(1), coord1(12), coord2(13), off_index(0), BED"
} else {
    Process_Tables $argv
}
