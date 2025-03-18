# Create clock with 21276ns period (47 kHz)
create_clock -period 21276.000 -name clk -add [get_ports clk]

# Input delays for each input port
set_input_delay -clock clk 100.000 [get_ports d_phase0]
set_input_delay -clock clk 100.000 [get_ports d_phase1]
set_input_delay -clock clk 100.000 [get_ports d_phase2]

# Output delays for each output port
set_output_delay -clock clk 100.000 [get_ports out_phase0]
set_output_delay -clock clk 100.000 [get_ports out_phase1]
set_output_delay -clock clk 100.000 [get_ports out_phase2]