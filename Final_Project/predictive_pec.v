module predictive_pec(
    input                   clk,
    input                   reset,
    input signed   [7:0]    current_phase_error,
    output reg signed   [7:0] predicted_error
);
    // Shift register to hold the last 4 phase error samples
    reg signed [7:0] error_reg [0:3];
    integer i;
    reg signed [9:0] sum;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 4; i = i+1)
                error_reg[i] <= 8'sd0;
            predicted_error <= 8'sd0;
        end else begin
            // Shift the register
            error_reg[3] <= error_reg[2];
            error_reg[2] <= error_reg[1];
            error_reg[1] <= error_reg[0];
            error_reg[0] <= current_phase_error;
            
            // Predict by averaging past 4 errors
            sum = error_reg[0] + error_reg[1] + error_reg[2] + error_reg[3];
            predicted_error <= sum >>> 2; // divide by 4
        end
    end
endmodule
