`timescale 1ns/1ps

module TripleParallelFIR_tb;

    // Clock/reset signals
    logic clk_sig;
    logic rst_sig;

    // DUT I/O: triple input streams, triple outputs
    logic signed [15:0] data_in_a, data_in_b, data_in_c;
    logic signed [63:0] data_out_a, data_out_b, data_out_c;

    // Memory for stimuli and address pointer
    parameter int STREAM_COUNT = 3;
    parameter int MEM_DEPTH = 131072;
    logic signed [15:0] test_data [0:MEM_DEPTH-1];
    int index;

    // Instantiate Unit Under Test
     FIR_Three_Parallel dut (
        .clk(clk_sig),
        .rst(rst_sig),
        .d_phase0(data_in_a),
        .d_phase1(data_in_b),
        .d_phase2(data_in_c),
        .out_phase0(data_out_a),
        .out_phase1(data_out_b),
        .out_phase2(data_out_c)
    );

    // Initialization and data loading
    initial begin
        // Load test vectors from local file
        $readmemb("input.data", test_data);

        // Initial conditions
        clk_sig = 0;
        rst_sig = 1;
        index   = 0;

        // Deassert reset after a short delay
        #21276 rst_sig = 0;
    end

    // Provide different streams from consecutive memory entries
    assign data_in_a = test_data[index];
    assign data_in_b = test_data[index + 1];
    assign data_in_c = test_data[index + 2];

    // Increment address pointer at each clock
    always_ff @(posedge clk_sig) begin
        if (!rst_sig && (index + STREAM_COUNT < MEM_DEPTH)) begin
            index <= index + STREAM_COUNT;
        end
    end

    // Clock generator: 47 kHz => 21276 ns period
    always #10638 clk_sig = ~clk_sig;

endmodule
