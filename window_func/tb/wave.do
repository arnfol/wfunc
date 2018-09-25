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
add wave -noupdate -expand -group apb -radix hexadecimal -childformat {{{/window_func_tb/pwdata[31]} -radix hexadecimal} {{/window_func_tb/pwdata[30]} -radix hexadecimal} {{/window_func_tb/pwdata[29]} -radix hexadecimal} {{/window_func_tb/pwdata[28]} -radix hexadecimal} {{/window_func_tb/pwdata[27]} -radix hexadecimal} {{/window_func_tb/pwdata[26]} -radix hexadecimal} {{/window_func_tb/pwdata[25]} -radix hexadecimal} {{/window_func_tb/pwdata[24]} -radix hexadecimal} {{/window_func_tb/pwdata[23]} -radix hexadecimal} {{/window_func_tb/pwdata[22]} -radix hexadecimal} {{/window_func_tb/pwdata[21]} -radix hexadecimal} {{/window_func_tb/pwdata[20]} -radix hexadecimal} {{/window_func_tb/pwdata[19]} -radix hexadecimal} {{/window_func_tb/pwdata[18]} -radix hexadecimal} {{/window_func_tb/pwdata[17]} -radix hexadecimal} {{/window_func_tb/pwdata[16]} -radix hexadecimal} {{/window_func_tb/pwdata[15]} -radix hexadecimal} {{/window_func_tb/pwdata[14]} -radix hexadecimal} {{/window_func_tb/pwdata[13]} -radix hexadecimal} {{/window_func_tb/pwdata[12]} -radix hexadecimal} {{/window_func_tb/pwdata[11]} -radix hexadecimal} {{/window_func_tb/pwdata[10]} -radix hexadecimal} {{/window_func_tb/pwdata[9]} -radix hexadecimal} {{/window_func_tb/pwdata[8]} -radix hexadecimal} {{/window_func_tb/pwdata[7]} -radix hexadecimal} {{/window_func_tb/pwdata[6]} -radix hexadecimal} {{/window_func_tb/pwdata[5]} -radix hexadecimal} {{/window_func_tb/pwdata[4]} -radix hexadecimal} {{/window_func_tb/pwdata[3]} -radix hexadecimal} {{/window_func_tb/pwdata[2]} -radix hexadecimal} {{/window_func_tb/pwdata[1]} -radix hexadecimal} {{/window_func_tb/pwdata[0]} -radix hexadecimal}} -subitemconfig {{/window_func_tb/pwdata[31]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[30]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[29]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[28]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[27]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[26]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[25]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[24]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[23]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[22]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[21]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[20]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[19]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[18]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[17]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[16]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[15]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[14]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[13]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[12]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[11]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[10]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[9]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[8]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[7]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[6]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[5]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[4]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[3]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[2]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[1]} {-height 16 -radix hexadecimal} {/window_func_tb/pwdata[0]} {-height 16 -radix hexadecimal}} /window_func_tb/pwdata
add wave -noupdate /window_func_tb/u_window_func/fsm_addr
add wave -noupdate -radix hexadecimal -childformat {{{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[0]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[1]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[2]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[3]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[4]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[5]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[6]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[7]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[8]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[9]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[10]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[11]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[12]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[13]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[14]} -radix hexadecimal} {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[15]} -radix hexadecimal}} -subitemconfig {{/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[0]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[1]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[2]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[3]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[4]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[5]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[6]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[7]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[8]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[9]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[10]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[11]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[12]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[13]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[14]} {-height 16 -radix hexadecimal} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram[15]} {-height 16 -radix hexadecimal}} {/window_func_tb/u_window_func/mem_gen[0]/u_spram/ram}
add wave -noupdate -group in /window_func_tb/in_tdata
add wave -noupdate -group in /window_func_tb/in_tlast
add wave -noupdate -group in /window_func_tb/in_tready
add wave -noupdate -group in /window_func_tb/in_tvalid
add wave -noupdate -group out /window_func_tb/out_tdata
add wave -noupdate -group out /window_func_tb/out_tlast
add wave -noupdate -group out /window_func_tb/out_tready
add wave -noupdate -group out /window_func_tb/out_tvalid
add wave -noupdate -group mult /window_func_tb/u_window_func/state
add wave -noupdate -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/a}
add wave -noupdate -group mult -radix hexadecimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/b}
add wave -noupdate -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[0]/u_complex_int_mult/z_reg[0]}
add wave -noupdate -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/a}
add wave -noupdate -group mult -radix decimal {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/b}
add wave -noupdate -group mult -radix decimal -childformat {{{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} -radix decimal} {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} -radix decimal}} -subitemconfig {{/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].re} {-height 16 -radix decimal} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0].im} {-height 16 -radix decimal}} {/window_func_tb/u_window_func/mult_gen[1]/u_complex_int_mult/z_reg[0]}
add wave -noupdate -group mult {/window_func_tb/u_window_func/tvalid_pipe[0]}
add wave -noupdate -group mult {/window_func_tb/u_window_func/tlast_pipe[0]}
add wave -noupdate -group mem -expand -group mem0 {/window_func_tb/u_window_func/mem_gen[0]/u_spram/addr}
add wave -noupdate -group mem -expand -group mem0 {/window_func_tb/u_window_func/mem_gen[0]/u_spram/clk}
add wave -noupdate -group mem -expand -group mem0 {/window_func_tb/u_window_func/mem_gen[0]/u_spram/cs}
add wave -noupdate -group mem -expand -group mem0 -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/data}
add wave -noupdate -group mem -expand -group mem0 -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[0]/u_spram/q}
add wave -noupdate -group mem -expand -group mem0 {/window_func_tb/u_window_func/mem_gen[0]/u_spram/we}
add wave -noupdate -group mem -expand -group mem1 -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[1]/u_spram/data}
add wave -noupdate -group mem -expand -group mem1 -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[1]/u_spram/addr}
add wave -noupdate -group mem -expand -group mem1 {/window_func_tb/u_window_func/mem_gen[1]/u_spram/we}
add wave -noupdate -group mem -expand -group mem1 {/window_func_tb/u_window_func/mem_gen[1]/u_spram/cs}
add wave -noupdate -group mem -expand -group mem1 -radix hexadecimal {/window_func_tb/u_window_func/mem_gen[1]/u_spram/q}
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
WaveRestoreCursors {{Cursor 1} {19260 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
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
WaveRestoreZoom {0 ps} {138944 ps}
