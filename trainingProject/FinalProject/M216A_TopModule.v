`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Module: M216A_TopModule
// Description:
//   Top-level MASH 1-1-1 delta-sigma modulator for the ECE M216A project.
//
//   Inputs:
//     - in_i  : 4-bit integer part of divide ratio (3..11)
//     - in_f  : 16-bit fractional part of divide ratio (0..65535)
//     - clk   : system clock (500 MHz)
//     - rst_n : active-low async reset
//
//   Output:
//     - out   : 4-bit divide value = in_i + out_f
//
//   Internals:
//     - Three cascaded delta-sigma stages (mash_stage):
//         stage1 integrates in_f
//         stage2 integrates e1
//         stage3 integrates e2
//       Each stage outputs a carry bit (c1/c2/c3) and an error term (e1/e2/e3).
//
//     - A noise_shaper block combines c1, c2, c3 to produce a small signed
//       fractional correction out_f in approximately [-3..+4].
//
//     - The final output is:
//         out = in_i + out_f
//       where out_f is 4-bit signed. For valid in_i (3..11) and out_f,
//       the result fits cleanly in 4 bits (0..15).
// -----------------------------------------------------------------------------

module M216A_TopModule (
    input        clk,       // 500 MHz clock
    input        rst_n,     // active-low reset
    input  [3:0] in_i,      // integer part (3..11)
    input [15:0] in_f,      // fractional part (0..65535)
    output [3:0] out        // instantaneous divide value
);

    // -------------------------------------------------------------------------
    // Wires between the three MASH stages.
    //   e1, e2, e3 : error outputs (16-bit)
    //   c1, c2, c3 : carry outputs (1-bit)
    // -------------------------------------------------------------------------
    wire [15:0] e1, e2, e3;
    wire        c1, c2, c3;

    // -------------------------------------------------------------------------
    // Instantiate the three first-order delta-sigma stages.
    // Each mash_stage:
    //   - accumulates its input (16-bit)
    //   - produces a 1-bit carry and a 16-bit error (sum without carry)
    // -------------------------------------------------------------------------

    // Stage 1: integrates the fractional input in_f
    mash_stage #(
        .WIDTH(16)
    ) stage1 (
        .clk   (clk),
        .rst_n (rst_n),
        .in_val(in_f),
        .e_out (e1),
        .c_out (c1)
    );

    // Stage 2: integrates e1
    mash_stage #(
        .WIDTH(16)
    ) stage2 (
        .clk   (clk),
        .rst_n (rst_n),
        .in_val(e1),
        .e_out (e2),
        .c_out (c2)
    );

    // Stage 3: integrates e2
    mash_stage #(
        .WIDTH(16)
    ) stage3 (
        .clk   (clk),
        .rst_n (rst_n),
        .in_val(e2),
        .e_out (e3),
        .c_out (c3)
    );

    // -------------------------------------------------------------------------
    // Noise shaper: combines c1, c2, c3 into a small signed fractional output.
    //
    // Implementation (Option 1):
    //   - carries treated as 0/+1
    //   - out_f is 4-bit signed, approximately in the range [-3..+4]
    // -------------------------------------------------------------------------
    wire signed [3:0] out_f;

    noise_shaper ns (
        .clk  (clk),
        .rst_n(rst_n),
        .c1   (c1),
        .c2   (c2),
        .c3   (c3),
        .out_f(out_f)
    );

    // -------------------------------------------------------------------------
    // Final output combine:
    //
    //   out = in_i + out_f
    //
    // in_i is 4-bit unsigned (3..11),
    // out_f is 4-bit signed (approx -3..+4),
    // so the sum is within 0..15 for valid inputs.
    //
    // We do the addition in a slightly wider signed intermediate to avoid
    // signedness surprises, then truncate back to 4 bits.
    // -------------------------------------------------------------------------
    reg [3:0] out_reg;

    // 5-bit signed intermediate: {0, in_i} is treated as positive,
    // out_f is already signed.
    wire signed [4:0] out_sum_full =
        $signed({1'b0, in_i}) + $signed(out_f);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= 4'd0;
        end else begin
            // For valid in_i and out_f, out_sum_full should be in 0..15.
            // We keep the lower 4 bits as the divide value.
            out_reg <= out_sum_full[3:0];
        end
    end

    assign out = out_reg;

endmodule
