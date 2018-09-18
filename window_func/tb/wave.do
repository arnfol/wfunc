onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /window_func_tb/clk
add wave -noupdate /window_func_tb/rst_n
add wave -noupdate -group apb /window_func_tb/psel
add wave -noupdate -group apb /window_func_tb/penable
add wave -noupdate -group apb /window_func_tb/pready
add wave -noupdate -group apb /window_func_tb/pwrite
add wave -noupdate -group apb -radix hexadecimal /window_func_tb/paddr
add wave -noupdate -group apb -radix hexadecimal /window_func_tb/prdata
add wave -noupdate -group apb -radix hexadecimal /window_func_tb/pwdata
add wave -noupdate -group in /window_func_tb/in_tdata
add wave -noupdate -group in /window_func_tb/in_tlast
add wave -noupdate -group in /window_func_tb/in_tready
add wave -noupdate -group in /window_func_tb/in_tvalid
add wave -noupdate -expand -group out /window_func_tb/out_tdata
add wave -noupdate -expand -group out /window_func_tb/out_tlast
add wave -noupdate -expand -group out /window_func_tb/out_tready
add wave -noupdate -expand -group out /window_func_tb/out_tvalid
add wave -noupdate -expand -group mult /window_func_tb/u_window_func/state
add wave -noupdate -expand -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/a}
add wave -noupdate -expand -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/b}
add wave -noupdate -expand -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/z_reg[0]}
add wave -noupdate -expand -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/a}
add wave -noupdate -expand -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/b}
add wave -noupdate -expand -group mult -radix decimal -childformat {{{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} -radix decimal} {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} -radix decimal}} -subitemconfig {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} {-height 16 -radix decimal} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} {-height 16 -radix decimal}} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0]}
add wave -noupdate -expand -group mult {/window_func_tb/u_window_func/tvalid_pipe[0]}
add wave -noupdate -expand -group mult {/window_func_tb/u_window_func/tlast_pipe[0]}
add wave -noupdate -expand -group mult {/window_func_tb/u_window_func/tvalid_pipe[10]}
add wave -noupdate -expand -group mult {/window_func_tb/u_window_func/tlast_pipe[10]}
add wave -noupdate -group mem {/window_func_tb/u_window_func/mem_gen[0]/u_spram/addr}
add wave -noupdate -group mem {/window_func_tb/u_window_func/mem_gen[0]/u_spram/clk}
add wave -noupdate -group mem {/window_func_tb/u_window_func/mem_gen[0]/u_spram/cs}
add wave -noupdate -group mem -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/data}
add wave -noupdate -group mem -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/q}
add wave -noupdate -group mem {/window_func_tb/u_window_func/mem_gen[0]/u_spram/we}
add wave -noupdate /window_func_tb/u_window_func/data_line_en
add wave -noupdate /window_func_tb/u_window_func/data_line_en_del
add wave -noupdate -group in_pipe1 /window_func_tb/u_window_func/in_tlast_pipe_
add wave -noupdate -group in_pipe1 /window_func_tb/u_window_func/in_hshake_pipe_
add wave -noupdate -group in_pipe1 /window_func_tb/u_window_func/in_tdata_pipe_
add wave -noupdate -group in_pipe1 /window_func_tb/u_window_func/sample_cntr
add wave -noupdate -group in_pipe2 /window_func_tb/u_window_func/in_tlast_pipe
add wave -noupdate -group in_pipe2 /window_func_tb/u_window_func/in_hshake_pipe
add wave -noupdate -group in_pipe2 /window_func_tb/u_window_func/in_tdata_pipe
add wave -noupdate -group in_pipe2 /window_func_tb/u_window_func/mem_rdata
add wave -noupdate /window_func_tb/u_window_func/tvalid_save
add wave -noupdate /window_func_tb/u_window_func/tlast_save
add wave -noupdate /window_func_tb/u_window_func/z_del
add wave -noupdate /window_func_tb/u_window_func/save_trans
add wave -noupdate /window_func_tb/u_window_func/z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1200366 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {669481 ps} {1778651 ps}
