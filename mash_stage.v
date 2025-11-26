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
    output reg [WIDTH-1:0]    e_out,
    output reg                c_out
);

    // -------------------------------------------------------------------------
    // Accumulator register
    // -------------------------------------------------------------------------
    reg [WIDTH-1:0] accumulator;

    // -------------------------------------------------------------------------
    // Sum calculation (WIDTH+1 bits to capture carry)
    // -------------------------------------------------------------------------
    wire [WIDTH:0] sum;
    assign sum = {1'b0, accumulator} + {1'b0, in_val};

    // -------------------------------------------------------------------------
    // Sequential logic
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset accumulator and outputs
            accumulator <= {WIDTH{1'b0}};
            e_out <= {WIDTH{1'b0}};
            c_out <= 1'b0;
        end else begin
            // Update accumulator with the lower WIDTH bits
            accumulator <= sum[WIDTH-1:0];
            
            // Output the error (lower WIDTH bits of sum)
            e_out <= sum[WIDTH-1:0];
            
            // Output the carry (MSB of sum)
            c_out <= sum[WIDTH];
        end
    end

endmodule
