`timescale 1ns/1ps

// ============================================================================
// Module: M216A_TopModule
// Description:
//   Top-level MASH 1-1-1 delta-sigma modulator for the ECE M216A project.
//
//   Inputs:
//     - clk   : system clock (500 MHz)
//     - rst_n : active-low async reset
//     - in_i  : 4-bit integer part of divide ratio (3..11)
//     - in_f  : 16-bit fractional part of divide ratio (0..65535)
//
//   Output:
//     - out   : 4-bit divide value = in_i + out_f
//
//   Architecture:
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
// ============================================================================

module M216A_TopModule (
    input wire clk,                 // 500 MHz clock
    input wire rst_n,               // active-low reset
    input wire [3:0] in_i,          // integer part, restricted to range of 3..11
    input wire [15:0] in_f,         // fractional part (0..65535)
    output wire [3:0] out           // instantaneous divide value
);

    // Connect Mash stages here...
    // Remember from the project diagram...
    // 3 Integrator stages, each produce a 16b error signal, e1, e2, e3 (tossed)
    // 3 Integrators, each produce a 1b carry signals, c1, c2, c3
    wire [15:0] e1, e2, e3;         // error outputs
    wire        c1, c2, c3;         // carry outputs (1b Quantizer)

    // ========================================================
    // INTEGRATOR STAGES
    // --------------------------------------------------------
    // Build the Integrators together...
    // Input on one end is in_
    // in_f -> stage 1
    // e1 -> stage 2
    // e2 -> stage 3
    // e3 -> discarded
    // 3 Outputs c1, c2, c3 go to the noise shaping later
    // ========================================================

    // Stage 1: integrates the fractional input in_f
    mash_stage #(
        .WIDTH   (16)
    ) stage1 (
        .clk     (clk),
        .rst_n   (rst_n),
        .in_val  (in_f),
        .e_out   (e1),
        .c_out   (c1)
    );

    // Stage 2: integrates e1
    mash_stage #(
        .WIDTH   (16)
    ) stage2 (
        .clk     (clk),
        .rst_n   (rst_n),
        .in_val  (e1),
        .e_out   (e2),
        .c_out   (c2)
    );

    // Stage 3: integrates e2
    mash_stage #(
        .WIDTH   (16)
    ) stage3 (
        .clk     (clk),
        .rst_n   (rst_n),
        .in_val  (e2),
        .e_out   (e3),
        .c_out   (c3)
    );

    // ========================================================
    // NOISE SHAPING
    // --------------------------------------------------------
    // Build the Noise Shaper...
    // c1, c2, c3 -> into the noise shaper
    // out_f -> mixed with in_N to get the OUT signal
    // OUT generated from out_f and in_i
    // ========================================================

    wire signed [3:0] out_f;

    noise_shaper ns (
        .clk    (clk),
        .rst_n  (rst_n),
        .c1     (c1),
        .c2     (c2),
        .c3     (c3),
        .out_f  (out_f)
    );


    // ========================================================
    // FINAL OUTPUT COMBINATION
    // --------------------------------------------------------
    // Combinational output: in_i + out_f
    // in_i is 4b unsigned, out_f is 4b signed
    // Result is 4b unsigned (lower bits of signed sum)
    // ========================================================

    // 5-bit signed intermediate to handle signed addition
    wire signed [4:0] out_sum_full = $signed({1'b0, in_i}) + $signed(out_f);

    // Output is combinational (noise_shaper output is already registered)
    assign out = out_sum_full[3:0];

endmodule

