module phase_error_calculator(
    input       clk,
    input       reset,
    input       up,
    input       down,
    output reg signed [7:0] phase_error
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            phase_error <= 8'sd0;
        else begin
            if (up)
                phase_error <= 8'sd1;
            else if (down)
                phase_error <= -8'sd1;
            else
                phase_error <= 8'sd0;
        end
    end
endmodule

