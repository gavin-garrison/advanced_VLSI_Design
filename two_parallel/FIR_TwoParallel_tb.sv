`timescale 1ns/1ps

module FIR_TwoParallel_tb;

    // Clock and Reset
    logic clk = 0;
    logic rst_n = 0;

    // Data I/O
    logic signed [15:0] input_a, input_b;
    logic signed [63:0] output_a, output_b;

    // Memory buffer and address index
    parameter int DATA_DEPTH = 131072;
    logic signed [15:0] input_memory [0:DATA_DEPTH-1];
    int idx = 0;

    // Instantiate Unit Under Test (UUT)
    FIR_TwoParallel_Custom dut (
        .clk(clk),
        .rst(~rst_n),
        .in_even(input_a),
        .in_odd(input_b),
        .out_even(output_a),
        .out_odd(output_b)
    );

    // Clock generation: 47kHz → 21276ns period
    always #10638 clk = ~clk;

    // Load input data and control test sequence
    initial begin
        $readmemb("input.data", input_memory);
        
        // Wait briefly before releasing reset
        #100;
        rst_n = 1;

        // Run simulation for sufficient time
        #(21276 * (DATA_DEPTH / 2));
        $finish;
    end

    // Feed data to filter inputs
    always_ff @(posedge clk) begin
        if (rst_n && idx < DATA_DEPTH - 1) begin
            idx <= idx + 2;
        end
    end

    // Assign current input samples
    assign input_a = input_memory[idx];
    assign input_b = input_memory[idx + 1];

endmodule
