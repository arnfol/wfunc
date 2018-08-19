onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /window_func_tb/clk
add wave -noupdate /window_func_tb/rst_n
add wave -noupdate /window_func_tb/pclk
add wave -noupdate /window_func_tb/psel
add wave -noupdate /window_func_tb/penable
add wave -noupdate /window_func_tb/pready
add wave -noupdate /window_func_tb/pwrite
add wave -noupdate -radix hexadecimal /window_func_tb/paddr
add wave -noupdate /window_func_tb/prdata
add wave -noupdate /window_func_tb/pwdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {311226221 ps} 0}
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
WaveRestoreZoom {311021732 ps} {311340962 ps}
