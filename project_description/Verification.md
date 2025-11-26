# Verification Strategy

The verification is performed using `M216A_Testbench.v`. It employs two main strategies:

## 1. Average Value Verification
Since the Delta-Sigma modulator's instantaneous output varies, its performance is verified by averaging the output over many cycles.

- **Method**:
    1.  Apply a static `in_i` and `in_f`.
    2.  Run simulation for `N_CYCLES` (e.g., 5000).
    3.  Sum the `out` values.
    4.  Calculate `Average = Sum / N_CYCLES`.
    5.  Compare with Expected: `Expected = in_i + (in_f / 65536.0)`.
    6.  Report Error.

- **Test Cases**:
    - **Mid-range**: `in_i=8, in_f=32000` (~8.488)
    - **Half**: `in_i=4, in_f=32768` (4.5)
    - **Small Fraction**: `in_i=7, in_f=1000`
    - **Near Integer**: `in_i=5, in_f=100`
    - **Edge Cases**: Min (`3.0`), Max (`11.999...`).

## 2. Noise Shaper Range Check
Ensures the combinatorial logic in the noise shaper never produces a value that exceeds the 4-bit signed range.

- **Method**:
    - Instantiates a separate `noise_shaper` (`ns_rand`).
    - Drives it with random 1-bit values for `c1, c2, c3` for 10,000 cycles.
    - **Check**: `out_f` must always be within `[-3, +4]`.
    - Reports violations if any.

