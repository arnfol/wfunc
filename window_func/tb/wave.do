onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /window_func_tb/clk
add wave -noupdate /window_func_tb/rst_n
add wave -noupdate -expand -group apb /window_func_tb/psel
add wave -noupdate -expand -group apb /window_func_tb/penable
add wave -noupdate -expand -group apb /window_func_tb/pready
add wave -noupdate -expand -group apb /window_func_tb/pwrite
add wave -noupdate -expand -group apb -radix hexadecimal /window_func_tb/paddr
add wave -noupdate -expand -group apb -radix hexadecimal /window_func_tb/prdata
add wave -noupdate -expand -group apb -radix hexadecimal /window_func_tb/pwdata
add wave -noupdate -expand -group in /window_func_tb/in_tdata
add wave -noupdate -expand -group in /window_func_tb/in_tlast
add wave -noupdate -expand -group in /window_func_tb/in_tready
add wave -noupdate -expand -group in /window_func_tb/in_tvalid
add wave -noupdate -expand -group out /window_func_tb/out_tdata
add wave -noupdate -expand -group out /window_func_tb/out_tlast
add wave -noupdate -expand -group out /window_func_tb/out_tready
add wave -noupdate -expand -group out /window_func_tb/out_tvalid
add wave -noupdate -expand -group dbg /window_func_tb/u_window_func/state
add wave -noupdate -expand -group dbg -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/a}
add wave -noupdate -expand -group dbg -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/b}
add wave -noupdate -expand -group dbg -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/z_reg[0]}
add wave -noupdate -expand -group dbg -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/a}
add wave -noupdate -expand -group dbg -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/b}
add wave -noupdate -expand -group dbg -radix decimal -childformat {{{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} -radix decimal} {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} -radix decimal}} -subitemconfig {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} {-height 16 -radix decimal} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} {-height 16 -radix decimal}} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0]}
add wave -noupdate {/window_func_tb/u_window_func/mem_gen[0]/u_spram/addr}
add wave -noupdate {/window_func_tb/u_window_func/mem_gen[0]/u_spram/clk}
add wave -noupdate {/window_func_tb/u_window_func/mem_gen[0]/u_spram/cs}
add wave -noupdate -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/data}
add wave -noupdate -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/q}
add wave -noupdate {/window_func_tb/u_window_func/mem_gen[0]/u_spram/we}
add wave -noupdate -radix hexadecimal /window_func_tb/u_window_func/fsm_addr
add wave -noupdate -radix hexadecimal /window_func_tb/u_window_func/paddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {961281 ps} 0}
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
WaveRestoreZoom {920471 ps} {1021625 ps}
