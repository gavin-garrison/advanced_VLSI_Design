`timescale 1ns/1ps

module TripleParallelPipeline_tb;

    // Clock & reset
    logic clk_sig;
    logic rst_sig;

    // DUT I/O
    logic signed [15:0] stream_a, stream_b, stream_c;
    logic signed [63:0] out_a, out_b, out_c;

    // Memory for feeding input
    parameter int MEM_CAPACITY = 131072;
    logic signed [15:0] sample_array [0:MEM_CAPACITY-1];
    logic [31:0] idx;

    // DUT instantiation
    top dut (
        .clk(clk_sig),
        .rst(rst_sig),
        .din0(stream_a),
        .din1(stream_b),
        .din2(stream_c),
        .dout0(out_a),
        .dout1(out_b),
        .dout2(out_c)
    );

    // Clock generation: ~47kHz → 21276ns period
    always #10638 clk_sig = ~clk_sig;

    // Initialization
    initial begin
        $readmemb("input.data", sample_array);
        clk_sig = 0;
        rst_sig = 1;
        #21276 rst_sig = 0;  // Deassert reset after one full period
    end

    // Index update and reset behavior
    always_ff @(posedge clk_sig) begin
        if (rst_sig) begin
            idx <= 0;
        end else if (idx < MEM_CAPACITY - 3) begin
            idx <= idx + 3;
        end
    end

    // Feed samples
    assign stream_a = sample_array[idx];
    assign stream_b = sample_array[idx + 1];
    assign stream_c = sample_array[idx + 2];

endmodule
