module adaptive_loop_filter(
    input                   clk,
    input                   reset,
    input                   up,             // Phase detector indicates recovered clock is early
    input                   down,           // or late
    input signed [15:0]     gain_adjustment, // From RL agent
    input signed   [7:0]    predicted_error, // From predictive PEC
    output reg [15:0]       control_word     // Frequency control word for the NCO
);
    reg signed [15:0] integrator;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integrator   <= 16'sd0;
            control_word <= 16'd1000;  // Base frequency control value
        end else begin
            if (up)
                integrator <= integrator + gain_adjustment + predicted_error;
            else if (down)
                integrator <= integrator - gain_adjustment - predicted_error;
            // Combine base frequency with integrator offset
            control_word <= 16'd1000 + integrator;
        end
    end
endmodule
