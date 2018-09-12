# -------------------------------------------------------------------
# config
# -------------------------------------------------------------------

# working library
set worklib work

set top_lvl window_func_tb

# VHDL and Verilog file extensions
set vhd_ext {vhd vhdl}
set ver_ext {v sv}
set default_path "../../src/window_func/tb/"

set vlog_opt {+incdir+../../src/common/}
set vcom_opt {}

# -------------------------------------------------------------------
# make lib
# -------------------------------------------------------------------

vlib $worklib

# -------------------------------------------------------------------
# compile functions
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
    global vlog_opt
    global vcom_opt

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
            vlog $vlog_opt -work $lib "$path$line" 
        } elseif {$ext in $vhd_ext} {
            vcom $vcom_opt -work $lib -2008 "$path$line" 
        } else {
            puts "ERROR! Unknown extension of the file $line"
        }
    }
}

#
proc run_from [list file [list path "$default_path"] [list lib $worklib]] {
    runfile "$path$file" "$path" "$lib"
}


# -------------------------------------------------------------------
# compile
# -------------------------------------------------------------------

run_from "src_list.txt" 
run_from "sim_list.txt" 




# -------------------------------------------------------------------
# simulate
# -------------------------------------------------------------------

vsim $top_lvl

# some windows
view structure
view signals
view wave

# signals
do "${default_path}wave.do"

# run
run -all

exit