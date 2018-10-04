# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: window_func.tcl
# Generated on: Thu Oct 04 19:45:37 2018

# Load Quartus II Tcl Project package
package require ::quartus::project
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "window_func"]} {
		puts "Project window_func is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists window_func]} {
		project_open -revision window_func window_func
	} else {
		project_new -revision window_func window_func
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 13.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:11:13  OCTOBER 04, 2018"
	set_global_assignment -name LAST_QUARTUS_VERSION 13.1
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name SYSTEMVERILOG_FILE ../src/common/complex_pkg.sv
	set_global_assignment -name SYSTEMVERILOG_FILE ../src/common/spram.sv
	set_global_assignment -name SYSTEMVERILOG_FILE ../src/window_func.sv
	set_global_assignment -name SYSTEMVERILOG_FILE ../src/complex_int_mult.sv
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE AUTO
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name SDC_FILE constr.sdc
	set_instance_assignment -name VIRTUAL_PIN ON -to rst_n
	set_instance_assignment -name VIRTUAL_PIN ON -to in_tvalid
	set_instance_assignment -name VIRTUAL_PIN ON -to in_tready
	set_instance_assignment -name VIRTUAL_PIN ON -to out_tvalid
	set_instance_assignment -name VIRTUAL_PIN ON -to out_tready
	set_instance_assignment -name VIRTUAL_PIN ON -to out_tlast
	set_instance_assignment -name VIRTUAL_PIN ON -to psel
	set_instance_assignment -name VIRTUAL_PIN ON -to penable
	set_instance_assignment -name VIRTUAL_PIN ON -to pwrite
	set_instance_assignment -name VIRTUAL_PIN ON -to in_tdata*
	set_instance_assignment -name VIRTUAL_PIN ON -to out_tdata*
	set_instance_assignment -name VIRTUAL_PIN ON -to paddr*
	set_instance_assignment -name VIRTUAL_PIN ON -to pwdata*
	set_instance_assignment -name VIRTUAL_PIN ON -to prdata*
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Compile project
	execute_flow -compile

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
