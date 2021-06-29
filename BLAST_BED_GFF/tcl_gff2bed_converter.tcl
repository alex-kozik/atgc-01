#!/usr/bin/tcl

proc Process_Tables { argv } {

    set f_in1         [open [lindex $argv 0] "r"]
    set f_out         [open [lindex $argv 1] "w"]

    set subj_column   [lindex $argv 2]
    set coord1_clmn   [lindex $argv 3]
    set coord2_clmn   [lindex $argv 4]

    set off_index     [lindex $argv 5]

    set feature_clmn  [lindex $argv 6]
    set gff_feature   [lindex $argv 7]

    set dummy_test  [lindex $argv 8]

    if { $dummy_test != "GFF" } {
	puts " ========================= "
	puts " DID NOT PASS  SANITY TEST "
	puts " LAST OPTION SHOULD BE GFF "
	puts " ========================= "
	exit
    }

    ####### READ GFF COORDS TABLE AND CONVERT TO BED #######
    set l 0
    set g 0
    while { [gets $f_in1 current_line] >= 0 } {
	set current_data [split   $current_line           "\t"]
	set subj_id      [lindex  $current_data   $subj_column]
	set coord1       [lindex  $current_data   $coord1_clmn]
	set coord2       [lindex  $current_data   $coord2_clmn]
	set feature      [lindex  $current_data   $feature_clmn]

	set coord1       [expr  $coord1 - $off_index]
	set coord2       [expr  $coord2 - $off_index]

	if {$coord1 < $coord2 && $feature == $gff_feature} {
		### BED starts are zero-based and GFF starts are one-based
		set coord1 [expr $coord1 - 1]
		puts $f_out "$subj_id\t$coord1\t$coord2"
		incr g
	}
        if {$coord1 >= $coord2} {
		puts        " + TOO GOOD TO BE TRUE + "
                puts $f_out " + TOO GOOD TO BE TRUE + "
		exit
        }
	incr l
    }
    close $f_in1
    close $f_out

    puts "============="
    puts " $l lines    "
    puts " $g features "
    puts " =========== "
    puts "     DONE    "
    puts " =========== "
}

if { $argc != 9 } {
    puts "Program usage:"
    puts "file_to_process, output_file, gff_id_column(0), coord1(3), coord2(4), off_index(0), feature_column(2), gff_feature(gene), GFF"
} else {
    Process_Tables $argv
}
