`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Module: noise_shaper
// Description:
//   Combines the three 1-bit carry outputs (c1, c2, c3) from a MASH 1-1-1
//   delta-sigma modulator into a small signed fractional output out_f.
//
//   Implements the digital transfer function:
//
//     out_f[n] = c1[n]
//                + (c2[n-1] - c2[n])
//                + (c3[n-2] - 2*c3[n-1] + c3[n])
//
//   In the z-domain, this corresponds to:
//     out_f(z) = c1(z) + (z^-1 - 1) c2(z) + (z^-1 - 1)^2 c3(z)
//
//   This shapes the quantization noise to high frequencies while keeping
//   the output fractional correction small (−3 to +4).
//
//   Here, c1, c2, c3 are treated as 0 or +1. The final out_f is a signed
//   4-bit value in approximately [−3, +4], which you will add to in_i in
//   the top module:
//
//     out = in_i + out_f;
// -----------------------------------------------------------------------------
// Notes:
//   - Active-low asynchronous reset (rst_n).
//   - out_f is registered (one-cycle latency).
//   - This is the "Option 1" implementation (no sign extension trick).
// -----------------------------------------------------------------------------

module noise_shaper (
    input        clk,
    input        rst_n,
    input        c1,            // carry from stage 1 (0 or 1)
    input        c2,            // carry from stage 2 (0 or 1)
    input        c3,            // carry from stage 3 (0 or 1)
    output reg signed [3:0] out_f  // fractional correction in [-3..+4]
);

    // -------------------------------------------------------------------------
    // Delay registers for c2 and c3:
    //   c2_z1  = c2[n-1]
    //   c3_z1  = c3[n-1]
    //   c3_z2  = c3[n-2]
    //
    // These are needed to implement the (z^-1 - 1) and (z^-1 - 1)^2 terms.
    // -------------------------------------------------------------------------
    reg c2_z1;
    reg c3_z1, c3_z2;

    // -------------------------------------------------------------------------
    // Sign-extend c1, c2, c3 and their delayed versions as small signed values.
    // We treat carry = 0 → 0, carry = 1 → +1.
    //
    // Using 4-bit signed is comfortable here:
    //   0  -> 0000 (0)
    //   1  -> 0001 (+1)
    // -------------------------------------------------------------------------
    wire signed [3:0] c1_s    = {3'b000, c1};
    wire signed [3:0] c2_s    = {3'b000, c2};
    wire signed [3:0] c2_z1_s = {3'b000, c2_z1};
    wire signed [3:0] c3_s    = {3'b000, c3};
    wire signed [3:0] c3_z1_s = {3'b000, c3_z1};
    wire signed [3:0] c3_z2_s = {3'b000, c3_z2};

    // -------------------------------------------------------------------------
    // Compute the individual terms:
    //
    //   term2[n] = c2[n-1] - c2[n]
    //   term3[n] = c3[n-2] - 2*c3[n-1] + c3[n]
    //
    // Each of these fits comfortably in a signed 4-bit range, but we use
    // a 5-bit intermediate (y_full) to be extra safe when summing.
    // -------------------------------------------------------------------------
    wire signed [3:0] term2 = c2_z1_s - c2_s;

    wire signed [3:0] term3 = c3_z2_s
                              - (c3_z1_s <<< 1)  // -2 * c3[n-1]
                              + c3_s;

    // Sum all contributions together:
    //   y_full = c1 + term2 + term3
    wire signed [4:0] y_full = $signed({1'b0, c1_s})
                             + $signed({1'b0, term2})
                             + $signed({1'b0, term3});

    // -------------------------------------------------------------------------
    // Sequential logic:
    //   - On reset: clear delays and out_f
    //   - Otherwise:
    //       * update delay registers (c2_z1, c3_z1, c3_z2)
    //       * register the fractional output out_f
    //
    // Note: The combinational y_full uses the "old" values of c2_z1, c3_z1,
    //       c3_z2 (from the previous cycle), which is exactly what we want:
    //       c2[n-1], c3[n-1], c3[n-2] participating in the current out_f[n].
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c2_z1 <= 1'b0;
            c3_z1 <= 1'b0;
            c3_z2 <= 1'b0;
            out_f <= 4'sd0;
        end else begin
            // Update delays for next cycle
            c2_z1 <= c2;
            c3_z2 <= c3_z1;
            c3_z1 <= c3;

            // Truncate y_full to 4 bits for fractional output.
            // For a well-designed MASH 1-1-1, y_full should stay in the
            // range [-3..+4], which fits in 4-bit signed.
            out_f <= y_full[3:0];
        end
    end

endmodule
