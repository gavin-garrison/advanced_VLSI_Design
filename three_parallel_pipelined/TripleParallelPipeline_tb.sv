`timescale 1ns/1ps

module TripleParallelPipeline_tb;

    // Clock & reset
    logic clk_sig;
    logic rst_sig;

    // DUT I/O: triple inputs, triple outputs
    logic signed [15:0] stream_a, stream_b, stream_c;
    logic signed [63:0] out_a, out_b, out_c;

    // Memory used for feeding input
    parameter int MEM_CAPACITY = 131072;
    logic signed [15:0] sample_array [0:MEM_CAPACITY-1];
    logic idx = 0;

    // Instantiate DUT
    three_parallel_pipeline dut (
        .clk(clk_sig),
        .rst(rst_sig),
        .din0(stream_a),
        .din1(stream_b),
        .din2(stream_c),
        .dout0(out_a),
        .dout1(out_b),
        .dout2(out_c)
    );

    // Initial setup
    initial begin
        $readmemb("input.data", sample_array); // Load input samples

        // Start with reset asserted
        clk_sig = 0;
        rst_sig = 1;
        idx = 0;

        // Deassert reset after one full clock cycle
        #21276 rst_sig = 0;
    end

    // Provide inputs: 3 samples per cycle
    always_ff @(posedge clk_sig) begin
        if (!rst_sig && (idx < MEM_CAPACITY - 3)) begin
            idx <= idx + 3;
        end
    end

    // Assign current input samples
    assign stream_a = sample_array[idx];
    assign stream_b = sample_array[idx + 1];
    assign stream_c = sample_array[idx + 2];

    // Clock generation: 47 kHz → 21276 ns period
    always #10638 clk_sig = ~clk_sig;

endmodule
