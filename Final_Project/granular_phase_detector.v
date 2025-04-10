`timescale 1ns/1ps
module granular_phase_detector(
    input clk,
    input reset,
    input d_in,
    input recovered_clk,
    output reg signed [3:0] phase_error  // 4-bit signed error, e.g., -8 to +7
);

    // Two-stage synchronizers for d_in and recovered_clk
    reg d_in_sync0, d_in_sync1;
    reg rec_clk_sync0, rec_clk_sync1;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            d_in_sync0 <= 0;
            d_in_sync1 <= 0;
            rec_clk_sync0 <= 0;
            rec_clk_sync1 <= 0;
        end else begin
            d_in_sync0 <= d_in;
            d_in_sync1 <= d_in_sync0;
            rec_clk_sync0 <= recovered_clk;
            rec_clk_sync1 <= rec_clk_sync0;
        end
    end

    // 8-bit counter that increments each clk cycle
    reg [7:0] cnt;
    always @(posedge clk or posedge reset) begin
        if (reset)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    // Detect rising edge on d_in and capture counter value
    reg d_in_prev;
    reg [7:0] d_in_time;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            d_in_prev <= 0;
            d_in_time <= 0;
        end else begin
            d_in_prev <= d_in_sync1;
            if (d_in_sync1 && !d_in_prev)
                d_in_time <= cnt;
        end
    end

    // Detect rising edge on recovered_clk and compute delta
    reg rec_clk_prev;
    reg [7:0] delta;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rec_clk_prev <= 0;
            delta <= 0;
        end else begin
            rec_clk_prev <= rec_clk_sync1;
            if (rec_clk_sync1 && !rec_clk_prev)
                delta <= cnt - d_in_time;
        end
    end

    // Parameter: expected delay for zero error
    parameter [7:0] EXPECTED_DELAY = 8'd5;
    
    // Compute phase_error = delta - EXPECTED_DELAY when a recovered_clk edge is detected
    always @(posedge clk or posedge reset) begin
        if (reset)
            phase_error <= 4'sd0;
        else if (rec_clk_sync1 && !rec_clk_prev)
            phase_error <= $signed({1'b0, delta}) - $signed({1'b0, EXPECTED_DELAY});
    end
endmodule
