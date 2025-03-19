module cdr_top(
    input  clk,
    input  reset,
    input  data_in,
    output recovered_clk
);
   wire up, down;
   wire [15:0] control_word;
   wire internal_recovered_clk;
   
   bang_bang_phase_detector pd (
      .d_in(data_in),
      .recovered_clk(internal_recovered_clk),
      .up(up),
      .down(down)
   );
   
   loop_filter lf (
      .clk(clk),
      .reset(reset),
      .up(up),
      .down(down),
      .control_word(control_word)
   );
   
   nco nco_inst (
      .clk(clk),
      .reset(reset),
      .freq_control(control_word),
      .out_clk(internal_recovered_clk)
   );
   
   assign recovered_clk = internal_recovered_clk;
endmodule