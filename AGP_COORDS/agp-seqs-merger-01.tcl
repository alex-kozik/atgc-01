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
    set f_out3 [open [lindex $argv 4] "w"]

    ### NUMBER OF CHROMOSOMES ###
    set n_chr 9

    ### ARRAY OF CONTIG SEQS ###
    global id_array

    ### READ SEQUENCES INTO MEMORY ###
    puts " READ SEQUENCES INTO ARRAY "
    set l 0
    while { [gets $f_in2 current_line] >= 0 } {
	set current_data [split   $current_line "\t"]
	set prime_id     [lindex  $current_data 0]
	set seqs_len     [lindex  $current_data 1]
	set dna_seqs     [lindex  $current_data 2]
	set id_array($prime_id)   $dna_seqs
	incr l
	puts "$prime_id\t***\t$seqs_len\t***\t$l"
    }
    close $f_in2

    ### CHROMOSOMES ###
    puts " CHROMOSOMES "
    set global chr
    set global agp
    set n 1
    while {$n <= $n_chr} {
        set chr($n) ""
	set agp($n)  1
        puts $n
        incr n
    }

    ### SEQS CONCATENATION ###
    puts " SEQS TO CONCATENATE "
    set k 0
    set NNN [string repeat N 100]
    puts " GAP 100-N "
    puts $NNN
    puts " --------- "
    while {[gets $f_in1 current_line] >= 0} {
	set current_data  [split   $current_line "\t"]

	set chr_n          [lindex  $current_data  0]
	set contig_id      [lindex  $current_data  1]
	set contig_dir     [lindex  $current_data  2]
	set terminal       [lindex  $current_data  3]

	set sequence $id_array($contig_id)

	if {$contig_dir == "-"} {
	    set sequence [Reverse_Complement_String $sequence]
	}

	if  {$terminal != "X"}  {
	    # set chr($chr_n) "$chr($chr_n)$id_array($contig_id)$NNN"
	    set chr($chr_n) "$chr($chr_n)$sequence$NNN"
	}

	if  {$terminal == "X"}  {
	    # set chr($chr_n) "$chr($chr_n)$id_array($contig_id)"
	    set chr($chr_n) "$chr($chr_n)$sequence"
	}

	### GFF COORDS (CONTIGS and GAPS)###

	### CONTIG COORDS ###
	set   seqs_len  [string length $sequence]
	set   seqs_end  [expr $agp($chr_n) + $seqs_len - 1]
	puts  $f_out2   "$chr_n\t$contig_id\t$agp($chr_n)\t$seqs_end\t$contig_dir\t$seqs_len"
	puts  $f_out3   "$chr_n\tAGP\tContig\t$agp($chr_n)\t$seqs_end\t\.\t$contig_dir\t\.\tID\=$contig_id;Length\=$seqs_len"
	set agp($chr_n) [expr [string length $chr($chr_n)] + 1]
	### GAP COORDS ###
	if  {$terminal != "X"}  {
	    set   gap_len     100
	    set   gap_start   [expr $agp($chr_n) - 100]
	    set   gap_end     [expr $agp($chr_n) -   1]
	    puts  $f_out2   "$chr_n\tgap\t$gap_start\t$gap_end\t\.\t$gap_len"
	    puts  $f_out3   "$chr_n\tAGP\tGap\t$gap_start\t$gap_end\t\.\t\.\t\.\tName\=Gap;Length\=$gap_len"
	}

	### PRINT OUT THE PROGRESS ###
	incr k
	puts "$k\t$contig_id\t$contig_dir\tCHR: $chr_n\t$terminal"

    }

    ### WRITE CHROMOSOME ASSEMBLY INTO OUTPUT FILE ###
    puts " WRITING OUTPUT FILE "
    set c 1
    while {$c <= $n_chr} {
	set  chr_seq  $chr($c)
	set  chr_len  [string length $chr_seq]
	puts $f_out1 "\>$c  L\:$chr_len \n$chr_seq"
	puts $c
	incr c
    }

    close $f_in1
    close $f_out1
    close $f_out2
    close $f_out3
    puts " .... "
    puts " DONE "
    puts " **** "
}

if {$argc != 5} {
    puts " Program usage: "
    puts " Contig_Table, Seqs_List, output_file1 (Fasta), output_file2 (Coords), output_file3 (GFF)"
} else {
    Process_Tables $argv
}

### THE END ###

