`timescale 1ns/1ps

module top (
    input logic clk,
    input logic rst,
    input logic signed [15:0] din0,
    input logic signed [15:0] din1,
    input logic signed [15:0] din2,
    output logic signed [63:0] dout0,
    output logic signed [63:0] dout1,
    output logic signed [63:0] dout2
);

    // Instantiate three pipelined FIR filter modules
    three_parallel_pipeline F0 (
        .clk(clk),
        .rst(rst),
        .d_in(din0),
        .d_out(dout0)
    );

    three_parallel_pipeline F1 (
        .clk(clk),
        .rst(rst),
        .d_in(din1),
        .d_out(dout1)
    );

    three_parallel_pipeline F2 (
        .clk(clk),
        .rst(rst),
        .d_in(din2),
        .d_out(dout2)
    );

endmodule
