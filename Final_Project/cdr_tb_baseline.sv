`timescale 1ns/1ps
module cdr_tb_baseline;
  reg clk;
  reg reset;
  reg data_in;
  wire recovered_clk;
  wire signed [7:0] phase_error_out;

  integer fd;
  integer i;  // Loop variable

  // Instantiate the baseline top-level design
  top_cdr_baseline uut (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .recovered_clk(recovered_clk),
    .phase_error_out(phase_error_out)
  );
  
  // Generate a system clock (100 MHz: 10 ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Open a file for logging phase_error_out
  initial begin
    fd = $fopen("simulation_output_baseline.txt", "w");
    if (fd == 0) begin
      $display("ERROR: Could not open simulation_output_baseline.txt for writing.");
      $finish;
    end else begin
      $display("Baseline testbench started at time %0t", $time);
    end
  end

  // Log phase_error_out at every positive edge of clk
  always @(posedge clk) begin
    $fwrite(fd, "%0t, %0d\n", $time, phase_error_out);
  end

  // Stimulus generation with jitter
  initial begin
    reset = 1;
    data_in = 0;
    #20;
    reset = 0;
    
    for (i = 0; i < 4000000; i = i + 1) begin
      #(20 + $urandom_range(-5, 5)) data_in = 1;
      #(10 + $urandom_range(-3, 3)) data_in = 0;
      if (i % 1000 == 0)
        #(50 + $urandom_range(-10, 10));
      else
        #(30 + $urandom_range(-5, 5));
    end
    
    #100;
    $fclose(fd);
    $stop;
  end
endmodule
