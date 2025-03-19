module top_rl_cdr(
    input  clk,
    input  reset,
    input  data_in,
    output recovered_clk,
    output signed [7:0] phase_error_out,
    output signed [15:0] gain_adjustment_out,
    output signed [7:0] predicted_error_out,
    output [15:0] control_word_out
);
   wire up, down;
   wire [15:0] control_word;
   wire internal_recovered_clk;
   wire signed [7:0] phase_error;
   wire signed [15:0] gain_adjustment;
   wire signed [7:0] predicted_error;
   wire signed [7:0] jitter; // For demonstration, derived from phase_error

   // Original bang-bang phase detector (assumed available)
   bang_bang_phase_detector pd (
      .d_in(data_in),
      .recovered_clk(internal_recovered_clk),
      .up(up),
      .down(down)
   );

   // Generate numeric phase error from up/down signals
   phase_error_calculator pecalc(
      .clk(clk),
      .reset(reset),
      .up(up),
      .down(down),
      .phase_error(phase_error)
   );
   
   // Derive jitter as the absolute value of phase_error
   assign jitter = (phase_error[7] == 1'b1) ? -phase_error : phase_error;
   
   // RL agent calculates an adaptive gain adjustment
   rl_agent_ml agent (
    .clk(clk),
    .reset(reset),
    .phase_error(phase_error),
    .jitter(jitter),
    .gain_adjustment(gain_adjustment)
    );

   
   // Predictive PEC computes an average of past errors
   predictive_pec pred_pec (
       .clk(clk),
       .reset(reset),
       .current_phase_error(phase_error),
       .predicted_error(predicted_error)
   );
   
   // Adaptive loop filter uses the RL agent and PEC outputs
   adaptive_loop_filter alf (
       .clk(clk),
       .reset(reset),
       .up(up),
       .down(down),
       .gain_adjustment(gain_adjustment),
       .predicted_error(predicted_error),
       .control_word(control_word)
   );
   
   // Modified NCO instantiation (no external freq_control)
   nco nco_inst (
      .clk(clk),
      .reset(reset),
      .out_clk(internal_recovered_clk)
   );
   
   assign recovered_clk = internal_recovered_clk;
   
   // Expose internal signals for simulation observation
   assign phase_error_out      = phase_error;
   assign gain_adjustment_out  = gain_adjustment;
   assign predicted_error_out  = predicted_error;
   assign control_word_out     = control_word;
   
endmodule
