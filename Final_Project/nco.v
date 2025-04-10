`timescale 1ns/1ps
module nco(
    input clk,
    input reset,
    input [15:0] freq_control,
    output reg out_clk
);
    // 16-bit accumulator for faster toggling in simulation
    reg [15:0] phase_accum;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_accum <= 16'd0;
            out_clk     <= 1'b0;
        end else begin
            phase_accum <= phase_accum + freq_control;
            // out_clk toggles based on the MSB of the 16-bit accumulator
            out_clk <= phase_accum[15];
        end
    end
endmodule
