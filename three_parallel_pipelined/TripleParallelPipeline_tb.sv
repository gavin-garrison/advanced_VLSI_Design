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
    int idx = 0;

    // Instantiate DUT
    three_parallel_pipeline dut (
        .clk(clk_sig),
        .rst(rst_sig),
        .din(stream_a),      // single input in the original
        .dout(out_a)         // single output in the original
    );

    // Initial setup
    initial begin
        $readmemb("input.data", sample_array); // read from local file

        // Start with reset asserted
        clk_sig = 0;
        rst_sig = 1;

        // Deassert after half cycle
        #10638 rst_sig = 0;
    end

    // Provide inputs
    always_ff @(posedge clk_sig) begin
        if (!rst_sig && (idx < MEM_CAPACITY - 3)) begin
            idx <= idx + 3;
        end
    end

    // just feed one stream
    assign stream_a = sample_array[idx];

    // Clock generation: ~47 kHz
    always #10638 clk_sig = ~clk_sig;

endmodule
