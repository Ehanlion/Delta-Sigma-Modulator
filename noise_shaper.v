// Module: noise_shaper
// Description:
//   This module implements a noise shaper for the delta-sigma modulator.
//   It combines the three carry outputs from the MASH stages to produce a
//   small signed fractional output.
//
//   Inputs:
//     - clk: clock signal
//     - rst_n: reset signal
//     - c1: carry output from the first MASH stage
//     - c2: carry output from the second MASH stage
//     - c3: carry output from the third MASH stage
//     
//   Outputs:
//     - out_f: signed fractional output, width is 4 bits
//
//   Notes:
//     - The noise shaper is a digital filter that shapes the quantization noise to high frequencies.