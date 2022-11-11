#!/usr/bin/tcl

proc Process_Tables { argv } {

    set f_in1 [open [lindex $argv 0] "r"]
    set f_out [open [lindex $argv 1] "w"]

    set scaffold_column  [lindex $argv 2]
    set coord1_column    [lindex $argv 3]
    set coord2_column    [lindex $argv 4]

    set off_index        [lindex $argv 5]

    set gff_column2      [lindex $argv 6]

    set dummy_test       [lindex $argv 7]

    if { $dummy_test != "AGP2GFF" } {
	puts " =========================== "
	puts "    DID NOT PASS DUI TEST    "
	puts " LAST OPTION MUST BE AGP2GFF "
	puts " =========================== "
	exit
    }

    ####### READ BLAST ALL_HITS TABLE AND CONVERT TO GFF #######
    set l 0
    set direction "MOOBA"
    while { [gets $f_in1 current_line] >= 0 } {
	set current_data   [split   $current_line           "\t"]
	set scaffold_id    [lindex  $current_data   $scaffold_column]
	set assy_coord1    [lindex  $current_data   $coord1_column]
	set assy_coord2    [lindex  $current_data   $coord2_column]

	set assy_coord1    [expr    $assy_coord1  - $off_index]
	set assy_coord2    [expr    $assy_coord2  - $off_index]

	set agp_column5    [lindex  $current_data   4]
	set agp_column6    [lindex  $current_data   5]
	set agp_column7    [lindex  $current_data   6]
	set agp_column8    [lindex  $current_data   7]
	set agp_column9    [lindex  $current_data   8]

	set gff_column3    "Something"
	set feature_id     "---------"
	if {$agp_column5 == "W"} {
		set gff_column3 "Contig"
		set feature_id  $agp_column6
	}
	if {$agp_column5 == "N"} {
                set gff_column3 "Gap"
		set feature_id  "NNNNNNNNN"
        }

	set direction "."
        if {$agp_column9 == "+"} {
                set direction "+"
        }
        if {$agp_column9 == "-"} {
                set direction "-"
        }

	set segment_len [ expr $assy_coord2 - $assy_coord1 + 1 ]

	if {$assy_coord1 < $assy_coord2} {
		puts $f_out "$scaffold_id\t$gff_column2\t$gff_column3\t$assy_coord1\t$assy_coord2\t\.\t$direction\t\.\tName=$gff_column3:$feature_id;Length\=$segment_len"
	}
        if {$assy_coord1 > $assy_coord2} {
		set direction "_NONSENSE_"
		puts        "      $direction         "
                puts        " + START OVER TOMORROW + "
                puts $f_out " + START OVER TOMORROW + "
                exit

        }
        if {$assy_coord1 == $assy_coord2} {
		set direction "_NULL_"
		puts        "      $direction         "
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

if { $argc != 8 } {
    puts "Program usage:"
    puts "file_to_process, output_file, scaffold_column(0), coord1(1), coord2(2), off_index(0), gff_column2, AGP2GFF"
} else {
    Process_Tables $argv
}
