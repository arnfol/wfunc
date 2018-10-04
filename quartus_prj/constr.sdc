create_clock -period 6.4 [get_ports clk]

set_input_delay -clock [get_clocks clk] -max 2.0 -add_delay [all_inputs]
set_input_delay -clock [get_clocks clk] -max 0.3 -add_delay [all_inputs]

set_output_delay -clock [get_clocks clk] -max 1.0 -add_delay [all_outputs]
set_output_delay -clock [get_clocks clk] -min -0.5 -add_delay [all_outputs]