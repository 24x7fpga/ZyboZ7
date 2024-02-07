#################################################################
#                       IN PROGRESS
#################################################################


create_clock -period 10.000 -name clk_in1 [get_ports clk_in1]

create_clock -period 10.000 -name wr_clk_out -waveform {0.000 5.000} [get_nets CLK_WIZ/inst/wr_clk_out]
create_clock -period 6.000 -name rd_clk_out -waveform {0.000 3.000} [get_nets CLK_WIZ/inst/rd_clk_out]

set_clock_groups -name asynchronous -asynchronous -group [get_clocks wr_clk_out] -group [get_clocks rd_clk_out]

set_input_delay -clock wr_clk_out -max 2.00 [all_inputs]
set_input_delay -clock wr_clk_out -min 1.00 [all_inputs]

set_input_delay -clock rd_clk_out -max 2.00 [all_inputs]
set_input_delay -clock rd_clk_out -min 1.00 [all_inputs]


set_output_delay -clock wr_clk_out -max 1.00 [all_outputs]
set_output_delay -clock wr_clk_out -min 1.00 [all_outputs]

set_output_delay -clock rd_clk_out -max 1.00 [all_outputs]
set_output_delay -clock rd_clk_out -min 1.00 [all_outputs]


