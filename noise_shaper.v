`timescale 1ns/1ps

// ============================================================================
// Module: noise_shaper
// Description:
//   This module implements a noise shaper for the delta-sigma modulator.
//   It combines the three carry outputs from the MASH stages to produce a
//   small signed fractional output.
//
//   Inputs:
//     - clk: clock signal
//     - rst_n: active-low asynchronous reset signal
//     - c1: carry output from the first MASH stage
//     - c2: carry output from the second MASH stage
//     - c3: carry output from the third MASH stage
//     
//   Outputs:
//     - out_f: signed fractional output, width is 4 bits
//
//   Notes:
//     - The noise shaper is a digital filter that shapes the quantization 
//       noise to high frequencies.
//     - Implements: out_f(z) = c1 + (z^-1 - 1)*c2 + (z^-1 - 1)^2*c3
// ============================================================================

module noise_shaper (
    input wire        clk,
    input wire        rst_n,
    input wire        c1,
    input wire        c2,
    input wire        c3,
    output reg signed [3:0] out_f
);

    // -------------------------------------------------------------------------
    // Delay registers for implementing the transfer function
    // out_f(z) = c1 + (z^-1 - 1)*c2 + (z^-1 - 1)^2*c3
    // -------------------------------------------------------------------------
    reg c2_z1;  // c2 delayed by 1 cycle (c2[n-1])
    reg c3_z1;  // c3 delayed by 1 cycle (c3[n-1])
    reg c3_z2;  // c3 delayed by 2 cycles (c3[n-2])

    // -------------------------------------------------------------------------
    // Intermediate signed terms for the noise shaping equation
    // -------------------------------------------------------------------------
    wire signed [2:0] term1;  // c1 (pass-through)
    wire signed [2:0] term2;  // (z^-1 - 1)*c2 = c2[n-1] - c2[n]
    wire signed [2:0] term3;  // (z^-1 - 1)^2*c3 = c3[n-2] - 2*c3[n-1] + c3[n]

    // -------------------------------------------------------------------------
    // Calculate terms using signed arithmetic
    // -------------------------------------------------------------------------
    // term1: c1 pass-through
    assign term1 = $signed({2'b0, c1});
    
    // term2: first-order differentiator on c2
    // (z^-1 - 1)*c2 = c2[n-1] - c2[n]
    assign term2 = $signed({2'b0, c2_z1}) - $signed({2'b0, c2});
    
    // term3: second-order differentiator on c3
    // (z^-1 - 1)^2*c3 = c3[n-2] - 2*c3[n-1] + c3[n]
    assign term3 = $signed({2'b0, c3_z2}) - ($signed({1'b0, c3_z1, 1'b0})) + $signed({2'b0, c3});

    // -------------------------------------------------------------------------
    // Sequential logic: Update delay registers and output
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all delay registers
            c2_z1 <= 1'b0;
            c3_z1 <= 1'b0;
            c3_z2 <= 1'b0;
            out_f <= 4'sd0;
        end else begin
            // Update delay registers (shift register)
            c2_z1 <= c2;
            c3_z1 <= c3;
            c3_z2 <= c3_z1;
            
            // Calculate output: sum of all three terms
            out_f <= $signed(term1) + $signed(term2) + $signed(term3);
        end
    end

endmodule
