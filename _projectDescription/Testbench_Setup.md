# Testbench Setup Documentation

## Files Created

### 1. **mash_stage.v** (Dummy Implementation)
- Parameterized module with `WIDTH=16`
- Inputs: `clk`, `rst_n`, `in_val[15:0]`
- Outputs: `e_out[15:0]`, `c_out`
- **Current Status**: Dummy implementation (outputs zeros)
- **TODO**: Implement actual accumulator logic

### 2. **noise_shaper.v** (Dummy Implementation)
- Inputs: `clk`, `rst_n`, `c1`, `c2`, `c3`
- Outputs: `out_f[3:0]` (signed)
- **Current Status**: Dummy implementation (outputs zero)
- **TODO**: Implement noise shaping transfer function

### 3. **M216A_TopModule.v** (Complete)
- Top-level module that instantiates:
  - 3x `mash_stage` modules (stage1, stage2, stage3)
  - 1x `noise_shaper` module
- Properly connects all signals
- Implements final addition: `out = in_i + out_f`
- **Status**: Complete and ready for testing

### 4. **EE216A_Testbench.v** (Complete)
Comprehensive testbench with:

#### Test Coverage:
- **4 Edge Cases**:
  - Min in_i (3) + Min in_f (0) → Expected: 3.0
  - Min in_i (3) + Max in_f (65535) → Expected: 3.999985
  - Max in_i (11) + Min in_f (0) → Expected: 11.0
  - Max in_i (11) + Max in_f (65535) → Expected: 11.999985

- **5 Random Cases**:
  - in_i=5, in_f=12345
  - in_i=7, in_f=32768 (exactly 0.5)
  - in_i=8, in_f=32000
  - in_i=4, in_f=1000
  - in_i=9, in_f=50000

#### Features:
- 500 MHz clock generation (2ns period)
- Averages output over 5000 cycles per test
- Calculates expected value: `in_i + in_f/65536`
- Compares measured vs expected with tolerance
- **Pass/Fail reporting** for each test
- **Summary statistics** at end
- VCD file generation for waveform viewing

#### Console Output:
Each test displays:
- Test number and description
- Input values (decimal and hex)
- Number of cycles averaged
- Sum of outputs
- Expected average
- Measured average
- Error
- PASS/FAIL status

### 5. **run_testbench.sh** (Complete)
Automated bash script that:
1. Sources `tool-setup` to load ModelSim
2. Cleans/creates work library
3. Compiles all Verilog files in order:
   - `mash_stage.v`
   - `noise_shaper.v`
   - `M216A_TopModule.v`
   - `EE216A_Testbench.v`
4. Runs simulation in headless mode (`vsim -c`)
5. Reports success/failure
6. Generates `M216A_TopModule.vcd` for waveform viewing

## How to Run

From the `deltaSigmaProject` directory:

```bash
./run_testbench.sh
```

The script will display all compilation and simulation output to the console.

## Expected Behavior (With Dummy Modules)

Since the `mash_stage` and `noise_shaper` are currently dummy implementations that output zeros:
- The `out` signal will always equal `in_i` (no fractional correction)
- **All tests will FAIL** because the measured average will be exactly `in_i` instead of `in_i + in_f/65536`

This is expected! The testbench infrastructure is working correctly.

## Next Steps

1. **Verify testbench runs**: Run `./run_testbench.sh` to ensure compilation works
2. **Implement `mash_stage.v`**: Add actual accumulator logic
3. **Implement `noise_shaper.v`**: Add noise shaping transfer function
4. **Re-run tests**: Tests should start passing once modules are implemented

## Debugging

If you encounter issues:
- Check `transcript` file for detailed ModelSim output
- View waveforms: `vsim M216A_TopModule.vcd` (requires GUI)
- Add `$display` statements to modules for debugging
- Verify tool-setup is sourcing correctly

## Notes

- The testbench uses a 1% error tolerance to account for finite averaging
- 5000 cycles should provide sufficient averaging for accurate results
- VCD file will be large (~MB) due to 500 MHz clock and long simulation

