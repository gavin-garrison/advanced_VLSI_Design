module rl_agent_ml(
    input                   clk,
    input                   reset,
    input signed   [7:0]    phase_error,  // e.g., -1, 0, +1 (could be a larger range in a real system)
    input signed   [7:0]    jitter,       // Similarly, expected to be a small value
    output reg signed [15:0] gain_adjustment
);
    // Dynamic weights and bias that will be updated
    reg signed [7:0] w1, w2, bias;
    // Learning rate (a small constant; adjust as needed)
    parameter signed [7:0] learning_rate = 8'sd1;
    // Reward: defined as negative absolute value of the phase error.
    // This means if phase_error is 1 or -1, reward = -1.
    reg signed [7:0] reward;
    
    // Compute reward = -abs(phase_error)
    always @(*) begin
        if (phase_error[7] == 1'b1) // negative value
            reward = -(-phase_error); // absolute value is -phase_error, then negate it
        else
            reward = -(phase_error);   // for positive values, simply negate
    end

    // Main logic: compute gain_adjustment and update weights each clock cycle
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize weights and bias with fixed starting values
            w1 <= 8'sd2;
            w2 <= 8'sd1;
            bias <= 8'sd0;
            gain_adjustment <= 16'sd0;
        end else begin
            // Compute the current gain adjustment
            gain_adjustment <= (phase_error * w1) + (jitter * w2) + bias;
            
            // Update weights using a simple delta rule:
            // new_weight = old_weight + (learning_rate * reward * input) scaled down.
            // The ">>> 3" acts as a scaling factor (dividing by 8) to avoid overly large updates.
            w1 <= w1 + ((learning_rate * reward * phase_error) >>> 3);
            w2 <= w2 + ((learning_rate * reward * jitter) >>> 3);
            bias <= bias + ((learning_rate * reward) >>> 3);
        end
    end

endmodule
