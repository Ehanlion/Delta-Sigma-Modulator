// Module: mash_stage
// Description:
//   This module implements a first-order delta-sigma modulator stage.
//   It accumulates the input value and produces a carry and an error term.
//
//   Parameters:
//     - WIDTH: width of the input and output values
//     = The default width is 16 bits.
//
//   Inputs:
//     - clk: clock signal
//     - rst_n: reset signal
//     - in_val: input value
//
//   Outputs:
//     - c_out: carry output, width is 1 (1b Quantizer)
//     - e_out: error output, width is [Width-1:0]
//
//   Notes:
//     - The input value is accumulated on every clock cycle.
//     - The carry output is the overflow/carry bit.
//     - The error output is the remaining sum without the carry.