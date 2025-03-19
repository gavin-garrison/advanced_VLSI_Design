module bang_bang_phase_detector(
    input  d_in,
    input  recovered_clk,
    output reg up,     // Signal to indicate recovered clock should speed up
    output reg down    // Signal to indicate recovered clock should slow down
);
    reg d_in_delayed;
    
    always @(posedge recovered_clk) begin
        d_in_delayed <= d_in;
        // Very simple edge detection:
        if (d_in && !d_in_delayed) begin
            up   <= 1;
            down <= 0;
        end 
        else if (!d_in && d_in_delayed) begin
            up   <= 0;
            down <= 1;
        end 
        else begin
            up   <= 0;
            down <= 0;
        end
    end
endmodule