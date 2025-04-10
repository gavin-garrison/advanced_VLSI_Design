`timescale 1ns/1ps
module top_cdr_baseline(
    input clk,
    input reset,
    input data_in,
    output recovered_clk,
    output signed [7:0] phase_error_out  // Exposed for logging
);

   wire signed [3:0] phase_error_4bit;
   wire signed [7:0] phase_error_8bit;
   wire [15:0] control_word;
   wire internal_recovered_clk;

   // Instantiate the granular phase detector
   granular_phase_detector gpd (
       .clk(clk),
       .reset(reset),
       .d_in(data_in),
       .recovered_clk(internal_recovered_clk),
       .phase_error(phase_error_4bit)
   );

   // Sign-extend the 4-bit error to 8 bits
   assign phase_error_8bit = {{4{phase_error_4bit[3]}}, phase_error_4bit};

   // Expose the 8-bit error for logging
   assign phase_error_out = phase_error_8bit;

   // Instantiate the static loop filter
   loop_filter_static lf (
       .clk(clk),
       .reset(reset),
       .phase_error(phase_error_8bit),
       .control_word(control_word)
   );

   // Instantiate the NCO
   nco nco_inst (
       .clk(clk),
       .reset(reset),
       .freq_control(control_word),
       .out_clk(internal_recovered_clk)
   );

   assign recovered_clk = internal_recovered_clk;
endmodule
