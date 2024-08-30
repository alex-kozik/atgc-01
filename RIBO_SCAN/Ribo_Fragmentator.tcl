### Ribo Fragmentator ###

### LEFT CUT SITE 
### CTGGAAACGACTCAGTCGGAGGTAG
### -------------AGTCGGAGGTAG 
### ---------------TCGGAGGTAG
### .........1....1....2....2
### 1...5....0....5....0....5

### RIGHT CUT SITE 
### CTGTTTAACAGCCTGCCCACC
### -----TAACAGCCTG------
### .........1....1....2.
### 1...5....0....5....0.

proc Search_Seqs { argv } {

    ### RIBO BOUNDARIES 
    set left_cut  "TCGGAGGTAG"
    set left_offset 15
    set right_cut "TAACAGCCTG"
    set right_offset 15
    # SHIFT SEARCH BY THIS LENGTH AFTER MATCH FOUND 
    set step_length 10
    # MIN SUBSTRING LENGTH 
    set length_min  8000
    set length_max 12000

    global fragm_array

    set f_in1 [open [lindex $argv 0] "r"]
    set f_out [open [lindex $argv 1] "w"]
    set f_log [open [lindex $argv 2] "w"]

    set id_list    ""
    set found_ids  ""

    ### LOAD SEQUENCE DNA FILE INTO MEMORY ###
    set m 1
    while {[gets $f_in1 current_line] >= 0} {
	set current_data [split $current_line "\t"]
	set id  [lindex $current_data 0]
	set seq_len [lindex $current_data 1]
	set seq [lindex $current_data 2]
	set seq_array($id) [string toupper $seq]
	set already_done [lsearch -exact $id_list $id]
	#####
	if {$seq_len >= 10000} {
		#####
		if {$already_done < 0} {
	    		set id_list [lappend id_list $id]
		}
		if {$already_done >= 0} {
	    		puts "========================="
	    		puts " DUPLICATION ... FOR $id "
	    		puts "========================="
	    		after 1000
	    		puts ""
		}
		# set m_mod [expr fmod($m,100)]
		set m_mod [expr fmod($m,1000)]
		if {$m_mod == 0} {
	    		puts "$m\t$id"
		}
		incr m
	}
    }

    puts "STEP 1 DONE"
    puts "$m  SEQUENCES LOADED"
    after 1000
    puts "SEARCH FOR MATCHES WITHIN SEQUENCES" 
    after 1000

    set step $step_length

    set q 0
    set c 0
    foreach id $id_list { 
	### START SEARCH HERE
        set t 0
        set u 0
	incr c
    	while { $t < [string length $seq_array($id)] } {
		### FIND LEFT CUT ###
		set find_me  [string first $left_cut $seq_array($id) $t]
		if { $find_me != -1 } {
			incr q
			incr u
			### SHIFT SEARCH BY STEP LENGTH 
			set t [expr $find_me + $step]
			### FIND RIGHT CUT ###
			set find_end [string first $right_cut $seq_array($id) $t]
			################################
			set find_me1 [expr $find_me + 1]
			set match_position $find_me1
			set end_position   $find_end
			set already_done [lsearch -exact $found_ids $id]
			if {$already_done < 0} {
				set found_ids [lappend found_ids $id]
		    	}
			##########################
			set m_mod [expr fmod($c,1000)]
			if {$m_mod == 0} {
	    			puts "... $c\t$q ..."
			}
			### EXTRACT SUBSTRINGS ###
			set find_length [expr $end_position - $find_me]
			if { $find_me >= 100 && $find_length >= $length_min && $find_length <= $length_max } {
				set sub_start  [expr $find_me - $left_offset] 
				set sub_end    [expr $end_position + $right_offset]
				set sub_length [expr $sub_end - $sub_start] 
				set sub_string [string range $seq_array($id) $sub_start $sub_end]
				puts $f_out "$id\_$c\_$u\t$sub_start\t$sub_end\t$sub_length\t$sub_string" 
			}
			##########################
			##########################
			### PRINT DATA TO LOG FILE 
			puts $f_log "$q\t$c\t$id\t$u\t$match_position\t$end_position"
			##########################
		}
		if { $find_me == -1 } {
			set t [string length $seq_array($id)]
			}
	} 
    }

    puts "WELL DONE"
    puts "$c SEQUENCES and $q MATCHES"
    puts "=========================="

    close $f_in1
    close $f_out
    close $f_log

    }

if {$argc != 4} {
	puts ""
	puts "Program usage:"
	puts "f_in1\(seq_tab\)  f_out  f_log  SEARCH"
} else {
	puts ""
	puts $argv
	Search_Seqs $argv
}
### THE END ###
###############
