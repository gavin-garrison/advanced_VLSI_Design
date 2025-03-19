module nco #(
    parameter [31:0] FREQ_CTRL = 32'h10000000  // Increased increment for simulation
)(
    input  clk,
    input  reset,
    output reg out_clk
);
    reg [31:0] phase_accum;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_accum <= 32'd0;
            out_clk     <= 0;
        end else begin
            phase_accum <= phase_accum + FREQ_CTRL;
            // Toggle out_clk when MSB changes
            out_clk <= phase_accum[31];
        end
    end
endmodule