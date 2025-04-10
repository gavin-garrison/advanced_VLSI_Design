## Clock Constraint
# Create a 100 MHz clock on the 'clk' input port
create_clock -period 10.000 [get_ports clk]

## Input/Output Port Constraints

# Data Input (data_in)
set_property PACKAGE_PIN W5 [get_ports data_in]
set_property IOSTANDARD LVCMOS33 [get_ports data_in]

# Reset (reset)
set_property PACKAGE_PIN V4 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Recovered Clock (recovered_clk)
set_property PACKAGE_PIN U8 [get_ports recovered_clk]
set_property IOSTANDARD LVCMOS33 [get_ports recovered_clk]

## Optional: Debug Signal Constraints
# Uncomment and set the proper pin assignments if you wish to route these signals to physical pins
#set_property PACKAGE_PIN Y5 [get_ports phase_error_out]
#set_property IOSTANDARD LVCMOS33 [get_ports phase_error_out]