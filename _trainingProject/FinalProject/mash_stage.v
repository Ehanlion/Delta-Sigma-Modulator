// -----------------------------------------------------------------------------
// Module: mash_stage
// Description:
//   One stage of a first-order delta-sigma (ΔΣ) modulator.
//   - 16-bit accumulator with feedback
//   - Adds a 16-bit input value each clock cycle
//   - Outputs:
//       c_out : carry bit (1-bit quantizer output)
//       e_out : 16-bit error / sum output (fed to next stage)
// -----------------------------------------------------------------------------
// Notes:
//   - Active-low asynchronous reset (rst_n). When rst_n = 0, internal state clears.
//   - WIDTH is parameterized (default 16), but you can just use the default.
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module mash_stage #(
    parameter WIDTH = 16          // bit-width of the accumulator and input
)(
    input                   clk,   // system clock
    input                   rst_n, // active-low reset
    input      [WIDTH-1:0]  in_val, // input value to accumulate (e.g., in_f or e1/e2)
    output reg [WIDTH-1:0]  e_out, // error output: sum without carry (WIDTH bits)
    output reg              c_out  // carry output: 1-bit quantizer output
);

    // Internal accumulator register
    reg [WIDTH-1:0] acc_reg;

    // Full adder result: WIDTH+1 bits to capture carry
    wire [WIDTH:0] sum_full;

    // Zero-extend both operands to WIDTH+1, then add
    assign sum_full = {1'b0, acc_reg} + {1'b0, in_val};

    // Separate sum and carry
    wire [WIDTH-1:0] sum_next   = sum_full[WIDTH-1:0]; // lower WIDTH bits
    wire             carry_next = sum_full[WIDTH];     // MSB = carry

    // Sequential logic: update accumulator, c_out, and e_out on each clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous active-low reset: clear state
            acc_reg <= {WIDTH{1'b0}};
            e_out   <= {WIDTH{1'b0}};
            c_out   <= 1'b0;
        end else begin
            // Normal operation: accumulate and output
            acc_reg <= sum_next;   // feedback for next cycle
            e_out   <= sum_next;   // error term = sum w/o carry
            c_out   <= carry_next; // quantizer output
        end
    end

endmodule
