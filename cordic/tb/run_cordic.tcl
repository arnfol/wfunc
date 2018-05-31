# -------------------------------------------------------------------
# config
# -------------------------------------------------------------------

# working library
set worklib work

set top_lvl cordic_tb

# VHDL and Verilog file extensions
set vhd_ext {vhd vhdl}
set ver_ext {v sv}

# set TclPath [file dirname [file normalize [info script]]]

# -------------------------------------------------------------------
# make lib
# -------------------------------------------------------------------

vlib $worklib

# -------------------------------------------------------------------
# compile
# -------------------------------------------------------------------

#
# This function runs compile for Verilog & VHDL files from file list
#
# Arguments:
#    file -- file list path
#    path -- additional path added to files from list (empty by default)
#    lib  -- target library (worklib by default)
#
proc runfile [list file [list path ""] [list lib $worklib]] {
    global ver_ext
    global vhd_ext

    # read file
    set fp [open $file r]
    set fdata [read -nonewline $fp]
    close $fp

    # delete comment lines
    set fdata [regsub -all -line {^#.*$} $fdata {}]

    # compile file list line by line
    set flines [split $fdata "\n"]
    foreach line $flines {
        # get file extension
        set ext [regsub -all {.*\.(\w+$)} $line {\1}]

        # compile file
        if {$ext in $ver_ext} {
            vlog -work $lib "$path$line"
        } elseif {$ext in $vhd_ext} {
            vcom -work $lib -2008 "$path$line"
        } else {
            puts "ERROR! Unknown extension of the file $line"
        }
    }
}
# puts "$TclPath"
# puts [pwd]
runfile "src_list_cordic.txt" "../"
runfile "sim_list_cordic.txt" "../"

# -------------------------------------------------------------------
# simulate
# -------------------------------------------------------------------

vsim -novopt $top_lvl

# some windows
view structure
view signals
view wave

# signals
# do wave.do

# run
run -all
