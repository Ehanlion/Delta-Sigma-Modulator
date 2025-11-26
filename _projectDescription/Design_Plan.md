# Design Implementation Plan

This document outlines the structural plan for the MASH 1-1-1 Delta-Sigma Modulator. The design is broken down into modular Verilog files to ensure modularity, ease of verification, and synthesis.

## 1. Proposed File Structure

We will implement the design using the following file organization within `deltaSigmaProject/`:

```
deltaSigmaProject/
├── M216A_TopModule.v      # Top-level module connecting all stages
├── mash_stage.v           # Reusable 1st-order MASH stage
├── noise_shaper.v         # Digital noise cancelling logic
└── EE216A_Testbench.v     # Top-level verification environment
```

---

## 2. Component Descriptions

### 2.1. MASH Stage (`mash_stage.v`)
This is the fundamental building block. We need three instances of this.

*   **Functionality**: A first-order accumulator with feedback. It accumulates the input value and produces an overflow (carry).
*   **Parameters**:
    *   `WIDTH`: Bit-width of the accumulator (Standard: 16).
*   **Inputs**:
    *   `clk`: System clock.
    *   `rst_n`: Active-low asynchronous reset.
    *   `in_val` [`WIDTH-1`:0]: Input value to be accumulated (from fractional input or previous stage error).
*   **Outputs**:
    *   `e_out` [`WIDTH-1`:0]: Quantization error (the residual sum in the accumulator).
    *   `c_out`: Carry bit (the 1-bit quantizer output, 0 or 1).
*   **Logic**:
    *   `{carry, sum} = accumulator + input`
    *   `accumulator <= sum`

### 2.2. Noise Shaper (`noise_shaper.v`)
This module processes the carry bits from the cascaded stages to cancel out lower-order quantization noise.

*   **Functionality**: Implements the transfer function $Y(z) = c_1 + (1-z^{-1})c_2 + (1-z^{-1})^2 c_3$.
*   **Inputs**:
    *   `clk`, `rst_n`
    *   `c1`: Carry from Stage 1.
    *   `c2`: Carry from Stage 2.
    *   `c3`: Carry from Stage 3.
*   **Outputs**:
    *   `out_f` [signed 3:0]: Fractional correction value.
*   **Internal Logic**:
    *   Must use flip-flops to create delayed versions of `c2` ($z^{-1}$) and `c3` ($z^{-1}, z^{-2}$).
    *   Arithmetic:
        *   `term1 = c1`
        *   `term2 = c2[n-1] - c2[n]`
        *   `term3 = c3[n-2] - 2*c3[n-1] + c3[n]`
        *   `out_f = term1 + term2 + term3`
    *   Range: The output is signed and typically fluctuates between -3 and +4.

### 2.3. Top Module (`M216A_TopModule.v`)
The wrapper that integrates the stages and produces the final integer divide ratio.

*   **Inputs**:
    *   `clk`, `rst_n`
    *   `in_i` [3:0]: Integer part of divide ratio (e.g., 3 to 11).
    *   `in_f` [15:0]: Fractional part of divide ratio.
*   **Outputs**:
    *   `out` [3:0]: Instantaneous integer divide value.
*   **Architecture**:
    1.  **Stage 1**: Input `in_f` $\rightarrow$ `c1`, `e1`.
    2.  **Stage 2**: Input `e1` $\rightarrow$ `c2`, `e2`.
    3.  **Stage 3**: Input `e2` $\rightarrow$ `c3`, `e3`.
    4.  **Noise Shaper**: Inputs `c1, c2, c3` $\rightarrow$ `out_f`.
    5.  **Adder**: `out = in_i + out_f`.
        *   *Note*: Requires careful signed addition handling. `in_i` is unsigned, `out_f` is signed.

---

## 3. Testbench Strategy (`EE216A_Testbench.v`)

The testbench verifies functionality and generates activity data for power analysis.

### 3.1. Signals & Setup
*   **Clock Generation**: 500 MHz clock (Period = 2ns).
*   **DUT Instantiation**: Connects to `M216A_TopModule`.
*   **VCD Dumping**: Critical for Power Analysis.
    ```verilog
    initial begin
        $dumpfile("M216A_TopModule.vcd");
        $dumpvars(0, EE216A_Testbench);
    end
    ```

### 3.2. Verification Method
Since the output toggles rapidly to represent a fractional value, we cannot check cycle-by-cycle equality. We use **Time Averaging**.

1.  **Apply Stimulus**: Set specific `in_i` and `in_f`.
2.  **Wait**: Allow transients to settle (approx 10 cycles).
3.  **Accumulate**: Sum the `out` value over $N$ cycles (e.g., $N=5000$).
4.  **Calculate Average**: $Avg = \frac{\sum out}{N}$.
5.  **Compare**: Check if $Avg \approx in\_i + \frac{in\_f}{2^{16}}$.
6.  **Pass/Fail**: Display error margin.

### 3.3. Metrics for Synthesis & Power
To evaluate the design properly using the provided scripts:

*   **Area**: The synthesis script (`scripting/DC_Synthesis.tcl`) will map the RTL to standard cells (`N16ADFP_StdCell`) and report the total cell area.
*   **Timing**:
    *   **Setup**: Ensures logic delays fit within the 2ns clock period (500 MHz).
    *   **Hold**: Ensures signals don't change too fast, causing race conditions.
*   **Power**:
    *   The testbench must run long enough to toggle internal nodes representative of real operation.
    *   `scripting/PrimeTime_PrimePower.tcl` will read the synthesized netlist (`.vg`) and the simulation dump (`.vcd`) to calculate dynamic and leakage power.

---

## 4. Next Steps
1.  Implement `mash_stage.v`.
2.  Implement `noise_shaper.v`.
3.  Implement `M216A_TopModule.v` connecting them.
4.  Populate `EE216A_Testbench.v` with the averaging logic and test vectors.
5.  Run simulation to verify correctness.
6.  Run synthesis and power scripts.

