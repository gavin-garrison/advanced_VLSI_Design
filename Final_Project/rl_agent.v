module rl_agent_ml(
    input                   clk,
    input                   reset,
    input signed   [7:0]    phase_error,  // e.g., a granular error, now possibly in a wider range
    input signed   [7:0]    jitter,       // A small value representing jitter
    output reg signed [15:0] gain_adjustment,
    output reg signed [7:0]  w1_out,
    output reg signed [7:0]  w2_out,
    output reg signed [7:0]  bias_out
);
    // Internal weight registers
    reg signed [7:0] w1, w2, bias;

    // Learning parameters
    parameter signed [7:0] LEARNING_RATE = 8'sd8;  // More aggressive learning
    parameter integer      SHIFT_FACTOR  = 2;       // Damping: divides update by 4
    parameter integer      WINDOW_SIZE   = 100;      // Batch update window

    // Weight clamping limits
    parameter signed [7:0] WEIGHT_MIN = -64;
    parameter signed [7:0] WEIGHT_MAX =  64;

    // Accumulators for batch update
    reg [6:0] cycle_count;  // Enough to count up to WINDOW_SIZE (here, 100)
    reg signed [15:0] accum_error;
    reg signed [15:0] accum_jitter;
    
    // We'll declare these at module level (for use in batch update)
    reg signed [15:0] total_error;
    reg signed [15:0] reward;

    // Refined reward: Quadratic scaling of error.
    // For example, reward = -((|total_error|^2)/REWARD_DIVISOR)
    parameter integer REWARD_DIVISOR = 4;

    // Continuous computation of gain_adjustment for driving downstream blocks
    always @(*) begin
        gain_adjustment = (phase_error * w1) + (jitter * w2) + bias;
    end

    // Batch update: Accumulate error over WINDOW_SIZE cycles then update weights
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w1          <= 8'sd2;
            w2          <= 8'sd1;
            bias        <= 8'sd0;
            cycle_count <= 0;
            accum_error <= 0;
            accum_jitter <= 0;
        end else begin
            accum_error  <= accum_error  + phase_error;
            accum_jitter <= accum_jitter + jitter;
            cycle_count  <= cycle_count + 1;
            
            if (cycle_count == (WINDOW_SIZE - 1)) begin
                total_error = accum_error; // total error over the batch

                // Compute a quadratic reward.
                // This reward will be negative and larger for higher absolute total_error.
                if (total_error < 0)
                    reward = -(((-total_error) * (-total_error)) / REWARD_DIVISOR);
                else
                    reward = -((total_error * total_error) / REWARD_DIVISOR);

                // Update weights using the batch accumulated error and reward.
                w1   <= clamp( w1 + ((LEARNING_RATE * reward * accum_error) >>> SHIFT_FACTOR) );
                w2   <= clamp( w2 + ((LEARNING_RATE * reward * accum_jitter) >>> SHIFT_FACTOR) );
                bias <= clamp( bias + ((LEARNING_RATE * reward) >>> SHIFT_FACTOR) );

                // Reset accumulators and cycle count for next batch
                accum_error  <= 0;
                accum_jitter <= 0;
                cycle_count  <= 0;
            end
        end
    end

    // Clamping function to restrict weights to [WEIGHT_MIN, WEIGHT_MAX]
    function signed [7:0] clamp;
        input signed [15:0] val;
        begin
            if (val > WEIGHT_MAX)
                clamp = WEIGHT_MAX;
            else if (val < WEIGHT_MIN)
                clamp = WEIGHT_MIN;
            else
                clamp = val[7:0];
        end
    endfunction

    // Expose internal weights for debugging
    always @(*) begin
        w1_out = w1;
        w2_out = w2;
        bias_out = bias;
    end
endmodule
