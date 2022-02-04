#############################################
###                                       ###
###       INVERTED REPEATS SCANNER        ###
###                                       ###
###           Alex Kozik 2022             ###
#############################################

###          REVERSE COMPLEMENT           ###
proc Reverse_Complement_String { seq_frw } {
        set string_rev {}
        set i [string length $seq_frw]
        while { $i > 0 } {
            append string_rev [string index $seq_frw [incr i -1]]
        }
        set seq_rev_compl [string map { A T G C C G T A N N } $string_rev]
        return $seq_rev_compl
}

###         SEQUENCE COMPLEXITY           ###
proc Sequence_Complexity { key_string } {
	set find_N "FALSE"
	set key_list   [split $key_string {}]
	set uniqueATGC [lsort -unique $key_list]
	set key_compl  [llength $uniqueATGC]
	if  { $key_compl >= 4 } {
	    set seq_compl "HIGH"
	}
	if { $key_compl <= 3 } {
            set seq_compl "LOW"
        }
	set find_N [lsearch $key_list N]
	if { $find_N != "FALSE" } {
	    set seq_compl "LOW"
	}
	return $seq_compl
	# puts $key_list
	# puts $uniqueATGC
	# puts $find_N
	# puts $seq_compl
}

#############################################
###             MAIN  BODY                ###
#############################################
proc Search_Seqs { argv } {

    # set debugging "TRUE"
    set debugging "FALSE"

    global fragm_array

    set f_in  [open [lindex $argv 0] "r"]
    set f_out [open [lindex $argv 1] "w"]
    ###          DUMMY ARGUMENT           ###
    set xsearch  [lindex $argv 2]
    ### MAX LENGTH OF LONG SEARCH SEGMENT ###
    set len_min  [lindex $argv 3]
    ### MAX LENGTH OF LONG SEARCH SEGMENT ###
    set len_max  [lindex $argv 4]
    ###    LENGTH OF SHORT SEARCH KEY     ###
    set key_len  [lindex $argv 5]
    #########################################
    ###  DUMMY ARGUMENT MUST BE "SEARCH"  ###
    if {$xsearch != "SEARCH"} {
	set oo 1
	while {$oo <= 12} {
	    puts " BAD BAD BAD ... $oo "
	    after 1000
	    incr oo
	}
	exit
    }
    #########################################
    ###    PRINT OUT LIST OF ARGUMENTS    ###
    puts "$f_in $f_out $len_min $len_max $key_len"
    #########################################
    ###   LOAD SEQUENCE FILE INTO MEMORY  ###
    set k 1
    set id_list ""
    while {[gets $f_in  current_line] >= 0} {
	set current_data [split $current_line "\t"]
	set name  [lindex $current_data 0]
	set seqs  [lindex $current_data 2]
	set id_list [lappend id_list $name]
	set seqs_array($name) [string toupper $seqs]
	puts "$k\t$name"
	incr k
    }
    #########################################
    ###    PRINT OUT LIST OF SEQUENCES    ###
    puts $id_list
    set  tir_count 0
    #########################################
    ###      MAIN SEARCH NESTED LOOP      ###
    foreach seq_id $id_list {
	###     SEQUENCE ACCESS WITHIN DATA ARRAY     ###
	set seq_len [string length $seqs_array($seq_id)]
	set seqs $seqs_array($seq_id)
	puts "$seq_id $seq_len"
	set s_start 0
	### SEARCH EACH SEQUENCE FOR INVERTED REPEATS ###
	while { $s_start < $seq_len } {
	    ###           DEFINE SEARCH KEY           ###
	    set s_end [expr $s_start + $key_len - 1]
	    set key_seq [string range $seqs $s_start $s_end]
	    set key_rev [Reverse_Complement_String $key_seq]
	    ###               DUBUGGING               ###
	    if { $debugging == "TRUE" } {
	    	puts "$key_seq\t$key_rev"
	    }
	    ###     SUBSEQUNCE TO SEARCH WITH KEY     ###
	    set sub_start [expr $s_end + $len_min + 1]
	    set sub_end   [expr $s_end + $len_max + 1]
	    set sub_seq   [string range $seqs $s_end $sub_end]
	    set segment   [string range $seqs $s_start $sub_end]
            ###               DUBUGGING               ###
            if { $debugging == "TRUE" } {
                puts "$sub_seq"
            }
	    set seq_compl "MAYBE"
	    set seq_compl [Sequence_Complexity $key_rev]
	    ###    FIND THE KEY WITHIN SUBSEQUENCE    ###
	    set find_me -1
	    if { $seq_compl == "HIGH" } {
	    	set find_me   [string first $key_rev $sub_seq 0]
	    }
	    if { $find_me != -1 } {
		incr tir_count
		set tir_start [expr $s_start - 3]
		set tir_end   [expr $s_end + 1 + $find_me + $key_len + 3]
		set tir_fragment [string range $seqs $tir_start $tir_end]
		set tir_length   [string length $tir_fragment]
		set tsd_left     [string range $seqs $tir_start [expr $tir_start + 2]]
		set tsd_right    [string range $seqs [expr $tir_end - 2] $tir_end]
		set tsd_status   "TSD_FALSE"
		if { $tsd_left == $tsd_right } {
		     set tsd_status   "TSD_TRUE"
		}
		puts $f_out "\>$seq_id\:$tir_count\:$tir_length \[$tir_start\:$tir_end\] \[$key_seq\:$key_rev\] \[$tsd_left\:$tsd_right\] $tsd_status \n$tir_fragment"
		set s_start $sub_end
		puts -nonewline " $s_start $find_me * "
	    }
            if { $find_me == -1 } {
		incr s_start
            }
	    ### puts -nonewline " $s_start "
	}
    }
    close $f_in
    close $f_out
}

###  LIST OF ARGUMENTS ###
if {$argc != 6} {
	puts ""
	puts "Program usage:"
	puts "f_in\(seq_db\)  f_out\(output\)  SEARCH   min_segment   max_segment  tir_length"
	exit
} else {
	puts ""
	puts $argv
	Search_Seqs $argv
}
