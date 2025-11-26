# Architecture Description

## Top-Level: `M216A_TopModule`
The top module integrates three cascaded MASH stages and a noise shaper.

- **Inputs**: `clk`, `rst_n`, `in_i[3:0]`, `in_f[15:0]`
- **Outputs**: `out[3:0]`

**Operation**:
1.  **Stage 1** integrates the fractional input `in_f`. It generates a carry `c1` and an error `e1`.
2.  **Stage 2** integrates the error from Stage 1 (`e1`). It generates `c2` and `e2`.
3.  **Stage 3** integrates the error from Stage 2 (`e2`). It generates `c3` and `e3`.
4.  **Noise Shaper** combines `c1`, `c2`, and `c3` to produce a signed fractional correction `out_f`.
5.  **Final Output**: `out = in_i + out_f`.

## Sub-Module: `mash_stage`
A standard first-order delta-sigma stage (accumulator).

- **Parameters**: `WIDTH` (default 16).
- **Logic**:
    - Accumulates the input value on every clock cycle.
    - `sum = accumulator + input`
    - `c_out` is the overflow/carry bit.
    - `e_out` is the remaining sum (error).

## Sub-Module: `noise_shaper`
Combines the 1-bit outputs from the three MASH stages to shape the quantization noise.

- **Function**:
    $$ out_f(z) = c1(z) + (z^{-1} - 1)c2(z) + (z^{-1} - 1)^2 c3(z) $$
    
- **Implementation**:
    - Uses delay registers to store previous values of `c2` (1 cycle) and `c3` (1 and 2 cycles).
    - Calculates differences:
        - `term2 = c2[n-1] - c2[n]`
        - `term3 = c3[n-2] - 2*c3[n-1] + c3[n]`
    - `out_f = c1 + term2 + term3`
    - Result is a signed 4-bit value, typically in the range [-3, +4].

