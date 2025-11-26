# Individual Module Testing Guide

This document describes the individual testbenches created for the `mash_stage` and `noise_shaper` modules.

## Purpose

These smaller, focused testbenches allow you to:
1. **Verify each module independently** before integrating into the top module
2. **Debug issues** more easily by isolating problems to specific modules
3. **Understand module behavior** through targeted test cases
4. **Iterate faster** during development (faster compile/sim times)

---

## MASH Stage Testing

### File: `mash_stage_tb.v`

Comprehensive testbench for the first-order delta-sigma accumulator.

#### Test Cases:

1. **Reset Functionality**
   - Verifies outputs are zero during reset
   - Ensures proper initialization

2. **Small Value Accumulation**
   - Adds small values (5) repeatedly
   - Should accumulate without generating carry
   - Displays accumulation pattern

3. **Large Value Accumulation**
   - Adds large values (0xF000) to force carry-out
   - Verifies carry generation

4. **Exact Overflow Test**
   - Adds 0x8000 twice (should overflow exactly at 16 bits)
   - Verifies: e_out=0x0000, c_out=1

5. **Alternating Input Pattern**
   - Tests with alternating 0x0001 and 0xFFFF
   - Checks accumulator behavior with varying inputs

6. **Fractional Input (Typical Use Case)**
   - Input = 32768 (represents 0.5 fractional)
   - Should produce carry approximately 50% of the time
   - Validates statistical behavior

#### Expected Behavior:

With the **dummy implementation**:
- All outputs will be zero
- Tests will FAIL (expected)

With **proper implementation**:
- Accumulator should increment by input value each cycle
- Carry should assert when accumulator overflows 16 bits
- Error output should be the lower 16 bits of the sum

#### Run Command:

```bash
./run_mash_stage_tb.sh
```

---

## Noise Shaper Testing

### File: `noise_shaper_tb.v`

Comprehensive testbench for the noise shaping digital filter.

#### Test Cases:

1. **All Zeros Input**
   - c1=c2=c3=0
   - Expected: out_f = 0

2. **DC Input on c1**
   - c1=1, c2=c3=0
   - Expected: out_f settles to +1
   - Tests pass-through of c1

3. **Pulse on c2**
   - Single pulse on c2 input
   - Tests the (z^-1 - 1)*c2 term
   - Should see transient response

4. **Pulse on c3**
   - Single pulse on c3 input
   - Tests the (z^-1 - 1)^2*c3 term
   - Should see second-order transient

5. **All Ones Input**
   - c1=c2=c3=1 continuously
   - Differentiator terms should cancel
   - Should settle to c1 value only

6. **Random Carry Patterns (Range Check)**
   - 1000 random combinations of c1, c2, c3
   - **Critical test**: Verifies out_f stays within [-3, +4]
   - Reports any violations

7. **Alternating Pattern**
   - c1 alternates between 0 and 1
   - Tests dynamic response

#### Expected Behavior:

With the **dummy implementation**:
- All outputs will be zero
- Tests will FAIL (expected)

With **proper implementation**:
- Should implement: out_f = c1 + (c2[n-1] - c2[n]) + (c3[n-2] - 2*c3[n-1] + c3[n])
- Output should ALWAYS stay within [-3, +4] range
- Differentiator terms should create transients that settle

#### Run Command:

```bash
./run_noise_shaper_tb.sh
```

---

## Testing Workflow

### Recommended Order:

1. **Test mash_stage first**
   ```bash
   ./run_mash_stage_tb.sh
   ```
   - Implement the accumulator logic in `mash_stage.v`
   - Verify all tests pass
   - This is the simpler module

2. **Test noise_shaper second**
   ```bash
   ./run_noise_shaper_tb.sh
   ```
   - Implement the noise shaping equation in `noise_shaper.v`
   - Verify all tests pass, especially the range check
   - This module is more complex (requires delay registers)

3. **Test full system**
   ```bash
   ./run_testbench.sh
   ```
   - Once both modules work individually
   - Verify the integrated system
   - Check averaging behavior

---

## Debugging Tips

### If mash_stage tests fail:

- Check accumulator register initialization in reset
- Verify the addition is 17-bit (to capture carry)
- Ensure proper bit slicing: `{c_out, e_out} = accumulator + in_val`
- Use non-blocking assignments (`<=`) in sequential block

### If noise_shaper tests fail:

- Verify delay registers (c2_z1, c3_z1, c3_z2) are updating correctly
- Check signed arithmetic - use `$signed()` for conversions
- Ensure the equation matches: `out_f = c1 + (c2_z1 - c2) + (c3_z2 - 2*c3_z1 + c3)`
- Watch for sign extension issues when mixing 1-bit and 4-bit values

### If range violations occur in noise_shaper:

- Double-check the differentiator math
- Verify bit widths in intermediate calculations
- Ensure proper signed arithmetic throughout
- The range [-3, +4] is theoretical for MASH 1-1-1; violations indicate logic errors

---

## Console Output

Both testbenches provide:
- Clear test numbering and descriptions
- Detailed signal values at each step
- **PASS/FAIL** indicators for each test
- Summary statistics at the end
- Helpful annotations (e.g., "← c2 pulse")

---

## Files Summary

| File | Purpose | Run Command |
|------|---------|-------------|
| `mash_stage_tb.v` | Test accumulator module | `./run_mash_stage_tb.sh` |
| `noise_shaper_tb.v` | Test noise shaper module | `./run_noise_shaper_tb.sh` |
| `EE216A_Testbench.v` | Test full system | `./run_testbench.sh` |

---

## Next Steps

1. Run the individual testbenches with dummy implementations (should fail)
2. Implement `mash_stage.v` logic
3. Re-run `./run_mash_stage_tb.sh` until all tests pass
4. Implement `noise_shaper.v` logic
5. Re-run `./run_noise_shaper_tb.sh` until all tests pass
6. Run full system test: `./run_testbench.sh`
7. Proceed to synthesis and power analysis

---

## Notes

- These testbenches are **self-checking** - they report PASS/FAIL automatically
- No need to manually inspect waveforms (though you can if needed)
- Fast iteration: each module test takes only seconds to run
- Comprehensive coverage: tests edge cases, typical cases, and statistical behavior

