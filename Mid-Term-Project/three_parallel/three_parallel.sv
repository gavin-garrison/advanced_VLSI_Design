`timescale 1ns/1ps

module FIR_Three_Parallel (
    input  logic clk,
    input  logic rst,
    input  logic signed [15:0] d_phase0,
    input  logic signed [15:0] d_phase1,
    input  logic signed [15:0] d_phase2,
    output logic signed [63:0] out_phase0,
    output logic signed [63:0] out_phase1,
    output logic signed [63:0] out_phase2
);

    // Filter parameters
    parameter int TOTAL_TAPS = 102;
    localparam int TAPS_PER_PHASE = TOTAL_TAPS / 3;

    // Coefficients memory
        localparam logic signed [31:0] coef [TAPS-1:0] = '{
            32'b11111111111110000101000100011100,
            32'b11111111111000110010100001001110,
            32'b11111111101101000000010001110011,
            32'b11111111010111011101110000111000,
            32'b11111110110101011110110010000100,
            32'b11111110000110010100100000001110,
            32'b11111101001100100110001111000010,
            32'b11111100001111001011001111010110,
            32'b11111011011001000010101110010000,
            32'b11111010110111110010101000110100,
            32'b11111010111000101110000110111000,
            32'b11111011100101000100011110011001,
            32'b11111100111110010111010100010101,
            32'b11111110111100000101010000001000,
            32'b00000001001011101110100110110101,
            32'b00000011010011110110001000001100,
            32'b00000100111001101000100110000110,
            32'b00000101100111111010111100110001,
            32'b00000101010101100010100111100101,
            32'b00000100001001000010111110000001,
            32'b00000010011000001101001000111111,
            32'b00000000100010111001101111101100,
            32'b11111111001010100000100110100001,
            32'b11111110101000000110001000011001,
            32'b11111111000100011111011111101110,
            32'b00000000010100111100110110111100,
            32'b00000001111101110111111000010001,
            32'b00000011011011001011111111100001,
            32'b00000100001100000000101100011010,
            32'b00000011111101111001110010001101,
            32'b00000010110011110110100011111110,
            32'b00000001000110010010100000101101,
            32'b11111111011011100111010000000100,
            32'b11111110011011010011001101101110,
            32'b11111110011111101100110010101111,
            32'b11111111101011011100101000111111,
            32'b00000001100110100010000111100001,
            32'b00000011100100101110100110111001,
            32'b00000100110011111011100110100011,
            32'b00000100101110000110100000111010,
            32'b00000011001000110110001101011100,
            32'b00000000011101000010001100100101,
            32'b11111101100011000100010101000111,
            32'b11111011100100000011000000011100,
            32'b11111011100011110001010101110010,
            32'b11111110001010001101000101110100,
            32'b00000011010011101001110010101011,
            32'b00001010001101001001100110000011,
            32'b00010001011110111100101000011100,
            32'b00010111100010100111010001011110,
            32'b00011010111110100000001110101110,
            32'b00011010111110100000001110101110,
            32'b00010111100010100111010001011110,
            32'b00010001011110111100101000011100,
            32'b00001010001101001001100110000011,
            32'b00000011010011101001110010101011,
            32'b11111110001010001101000101110100,
            32'b11111011100011110001010101110010,
            32'b11111011100100000011000000011100,
            32'b11111101100011000100010101000111,
            32'b00000000011101000010001100100101,
            32'b00000011001000110110001101011100,
            32'b00000100101110000110100000111010,
            32'b00000100110011111011100110100011,
            32'b00000011100100101110100110111001,
            32'b00000001100110100010000111100001,
            32'b11111111101011011100101000111111,
            32'b11111110011111101100110010101111,
            32'b11111110011011010011001101101110,
            32'b11111111011011100111010000000100,
            32'b00000001000110010010100000101101,
            32'b00000010110011110110100011111110,
            32'b00000011111101111001110010001101,
            32'b00000100001100000000101100011010,
            32'b00000011011011001011111111100001,
            32'b00000001111101110111111000010001,
            32'b00000000010100111100110110111100,
            32'b11111111000100011111011111101110,
            32'b11111110101000000110001000011001,
            32'b11111111001010100000100110100001,
            32'b00000000100010111001101111101100,
            32'b00000010011000001101001000111111,
            32'b00000100001001000010111110000001,
            32'b00000101010101100010100111100101,
            32'b00000101100111111010111100110001,
            32'b00000100111001101000100110000110,
            32'b00000011010011110110001000001100,
            32'b00000001001011101110100110110101,
            32'b11111110111100000101010000001000,
            32'b11111100111110010111010100010101,
            32'b11111011100101000100011110011001,
            32'b11111010111000101110000110111000,
            32'b11111010110111110010101000110100,
            32'b11111011011001000010101110010000,
            32'b11111100001111001011001111010110,
            32'b11111101001100100110001111000010,
            32'b11111110000110010100100000001110,
            32'b11111110110101011110110010000100,
            32'b11111111010111011101110000111000,
            32'b11111111101101000000010001110011,
            32'b11111111111000110010100001001110,
            32'b11111111111110000101000100011100
        };
         // Internal buffers for each phase
    logic signed [15:0] buf_phase0 [TAPS_PER_PHASE-1:0];
    logic signed [15:0] buf_phase1 [TAPS_PER_PHASE-1:0];
    logic signed [15:0] buf_phase2 [TAPS_PER_PHASE-1:0];

    // Combinational sums
    logic signed [63:0] sum0, sum1, sum2, sum_01, sum_12, sum_012;
    // Internal pipeline storage
    logic signed [63:0] sum2_reg;
    logic signed [63:0] h1h2_diff_reg;

    // Additional partial sums
    logic signed [63:0] partial_01_minus_h1, partial_12_minus_h1;
    logic signed [63:0] partial_012_minus_01, partial_0_minus_sum2reg;

    // Extra arithmetic signals
    assign partial_01_minus_h1  = sum_01 - sum1;
    assign partial_12_minus_h1  = sum_12 - sum1;
    assign partial_012_minus_01 = sum_012 - partial_01_minus_h1;
    assign partial_0_minus_sum2reg = sum0 - sum2_reg;

    // Data buffer shifting and partial sum hold
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum2_reg      <= '0;
            h1h2_diff_reg <= '0;
            for (int i = 0; i < TAPS_PER_PHASE; i++) begin
                buf_phase0[i] <= '0;
                buf_phase1[i] <= '0;
                buf_phase2[i] <= '0;
            end
        end else begin
            // Shift
            for (int i = TAPS_PER_PHASE-1; i > 0; i--) begin
                buf_phase0[i] <= buf_phase0[i-1];
                buf_phase1[i] <= buf_phase1[i-1];
                buf_phase2[i] <= buf_phase2[i-1];
            end
            // Insert new sample
            buf_phase0[0] <= d_phase0;
            buf_phase1[0] <= d_phase1;
            buf_phase2[0] <= d_phase2;

            sum2_reg      <= sum2;
            h1h2_diff_reg <= partial_12_minus_h1;
        end
    end

    // Combinational multiply-accumulate
    always_comb begin
        sum0  = '0;
        sum1  = '0;
        sum2  = '0;
        sum_01  = '0;
        sum_12  = '0;
        sum_012 = '0;

        for (int i = 0; i < TAPS_PER_PHASE; i++) begin
            sum0  += buf_phase0[i] * coefs[3*i];
            sum1  += buf_phase1[i] * coefs[3*i + 1];
            sum2  += buf_phase2[i] * coefs[3*i + 2];

            sum_01  += (buf_phase0[i] + buf_phase1[i]) * 
                       (coefs[3*i] + coefs[3*i+1]);
            sum_12  += (buf_phase1[i] + buf_phase2[i]) * 
                       (coefs[3*i+1] + coefs[3*i+2]);
            sum_012 += (buf_phase0[i] + buf_phase1[i] + buf_phase2[i]) * 
                       (coefs[3*i] + coefs[3*i+1] + coefs[3*i+2]);
        end
    end

    // Final outputs, scaled
    assign out_phase0 = (partial_0_minus_sum2reg + h1h2_diff_reg) >>> 31;
    assign out_phase1 = (partial_01_minus_h1  - partial_0_minus_sum2reg) >>> 31;
    assign out_phase2 = (partial_012_minus_01 - partial_12_minus_h1)     >>> 31;

endmodule
