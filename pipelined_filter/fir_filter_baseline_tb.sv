//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 01:43:59 PM
// Design Name: 
// Module Name: fir_filter_baseline_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module fir_filter_baseline_tb;

    logic clk;
    logic rst;
    logic signed [15:0] din;
    logic signed [63:0] dout;

    parameter MEM_SIZE = 131072;
    logic signed [15:0] sin [MEM_SIZE-1:0];
    int address;

    Pipelined_FIR dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout)
    );

    always #10638 clk = ~clk;

    initial begin
        $readmemb("input.data", sin);
    
        clk = 0;
        rst = 1;
        address = 0;
    
        #50000;     // Wait for at least 1 full clock cycle
        rst = 0;
    
        #500000 $finish;
    end

    assign din = sin[address];

    always @(posedge clk) begin
        if (!rst && address < MEM_SIZE - 1)
            address <= address + 1;
    end

endmodule

