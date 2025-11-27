`timescale 1ns/1ps

// ============================================================================
// Module: mash_stage
// Description:
//   This module implements a first-order delta-sigma modulator stage.
//   It accumulates the input value and produces a carry and an error term.
//
//   Parameters:
//     - WIDTH: width of the input and output values (default: 16 bits)
//
//   Inputs:
//     - clk: clock signal
//     - rst_n: active-low asynchronous reset signal
//     - in_val: input value to accumulate [WIDTH-1:0]
//
//   Outputs:
//     - c_out: carry output, width is 1 bit (1-bit Quantizer)
//     - e_out: error output, width is [WIDTH-1:0]
//
//   Notes:
//     - The input value is accumulated on every clock cycle.
//     - The carry output is the overflow/carry bit.
//     - The error output is the remaining sum without the carry.
// ============================================================================

module mash_stage #(
    parameter WIDTH = 16
)(
    input wire                clk,
    input wire                rst_n,
    input wire [WIDTH-1:0]    in_val,
    output wire [WIDTH-1:0]   e_out,  // Wire connected to accumulator
    output wire               c_out   // Combinational carry output
);

    // -------------------------------------------------------------------------
    // Accumulator register (also serves as e_out directly)
    // -------------------------------------------------------------------------
    reg [WIDTH-1:0] accumulator;

    // -------------------------------------------------------------------------
    // Sum calculation (WIDTH+1 bits to capture carry)
    // -------------------------------------------------------------------------
    wire [WIDTH:0] sum;
    assign sum = {1'b0, accumulator} + {1'b0, in_val};

    // -------------------------------------------------------------------------
    // Outputs are combinational (reduces register count)
    // -------------------------------------------------------------------------
    assign e_out = accumulator;
    assign c_out = sum[WIDTH];  // Combinational overflow signal

    // -------------------------------------------------------------------------
    // Sequential logic: only update accumulator
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= {WIDTH{1'b0}};
        end else begin
            accumulator <= sum[WIDTH-1:0];
        end
    end

endmodule
