module loop_filter(
    input         clk,
    input         reset,
    input         up,
    input         down,
    output reg [15:0] control_word
);
    reg signed [15:0] integrator;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integrator   <= 0;
            control_word <= 16'd1000; // Initial frequency control value
        end 
        else begin
            if (up)
                integrator <= integrator + 1;
            else if (down)
                integrator <= integrator - 1;
            // Update control word; this constant offset sets the nominal frequency
            control_word <= 16'd1000 + integrator;
        end
    end
endmodule