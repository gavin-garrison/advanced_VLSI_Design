`timescale 1ns/1ps
module loop_filter_static(
    input clk,
    input reset,
    input signed [7:0] phase_error,  // 8-bit phase error (from sign extension)
    output reg [15:0] control_word   // Frequency control word for the NCO
);
    reg signed [15:0] integrator;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integrator   <= 16'sd0;
            control_word <= 16'd1000; // Base frequency value
        end else begin
            // Simple integrator: if phase_error < 0, increment; if > 0, decrement
            if (phase_error < 0)
                integrator <= integrator + 1;
            else if (phase_error > 0)
                integrator <= integrator - 1;
            control_word <= 16'd1000 + integrator;
        end
    end
endmodule
