# Group 39 Synthesis Guide

## Overview
This directory contains the synthesis scripts for the M216A Delta-Sigma Modulator project.

## Required Files
The synthesis requires these Verilog source files:
- `M216A_TopModule.v` - Top-level module
- `mash_stage.v` - First-order delta-sigma accumulator
- `noise_shaper.v` - Noise shaping filter

## Quick Start

### Running Synthesis
```bash
./run_synthesis.sh
```

This single command will:
1. Source the tool setup
2. Create necessary directories (WORK, alib-52)
3. Run Design Compiler synthesis
4. Generate all required reports

## Generated Reports

The synthesis generates four main reports required for the project:

### 1. `Group_39.Area`
- Contains area breakdown by hierarchy
- Shows gate count and cell area
- Reports total area in square microns

### 2. `Group_39.Power`
- Reports power consumption by hierarchy
- Includes dynamic and leakage power
- Breakdown by sub-modules

### 3. `Group_39.TimingSetup`
- Setup timing analysis (max delay)
- Lists critical paths
- Shows slack values for setup timing

### 4. `Group_39.TimingHold`
- Hold timing analysis (min delay)
- Lists hold violations if any
- Shows slack values for hold timing

## Additional Output Files

### Synthesized Netlist
- `M216A_TopModule.vg` - Gate-level Verilog netlist
  - Can be used for post-synthesis simulation
  - Shows actual gates from TSMC 16nm library

### Timing Files
- `M216A_TopModule.sdf` - Standard Delay Format file
  - Contains gate delays for back-annotation
  
- `M216A_TopModule.sdc` - Synopsys Design Constraints
  - Can be used for further analysis

## Design Specifications

### Clock Configuration
- **Frequency**: 500 MHz
- **Period**: 2.0 ns
- **Clock Uncertainty**: 0.05 ns
- **Clock Port**: `clk`

### Technology Library
- **Process**: TSMC 16nm (N16ADFP)
- **Corner**: Slow-Slow (ss0p72v125c) for max delay
- **Min Corner**: Fast-Fast (ff0p88vm40c) for min delay

### Input/Output Delays
- Input delay: 0.4 ns (max), 0.2 ns (min)
- Output delay: 0.4 ns (max), 0.2 ns (min)

## Troubleshooting

### Synthesis Fails
1. Check that all Verilog files exist in the current directory
2. Verify tool-setup sources correctly
3. Check command.log for detailed error messages
4. Ensure WORK and alib-52 directories have write permissions

### Missing Reports
If any of the four reports are missing after synthesis:
1. Check for compilation errors in command.log
2. Verify the design meets timing constraints
3. Look for errors in the synthesis flow

### Timing Violations
If setup or hold timing violations occur:
- Review the timing reports for critical paths
- May need to adjust clock period or I/O delays
- Consider adding pipeline stages if needed

## Manual Synthesis (Advanced)

If you need to run synthesis manually:

```bash
# Source tools
source tool-setup

# Create directories
mkdir -p WORK alib-52

# Run Design Compiler
dc_shell -f Group_39.tcl
```

## Script Details

### `Group_39.tcl`
Main synthesis TCL script that:
- Configures Design Compiler
- Reads and elaborates the design
- Sets timing constraints
- Runs compilation
- Generates reports

### `run_synthesis.sh`
Bash wrapper script that:
- Sets up environment
- Creates directories
- Invokes dc_shell
- Verifies output files

## Notes

- Synthesis may take 1-5 minutes depending on server load
- The script uses multi-step compilation for best QoR (Quality of Results)
- Area optimization is set to minimize total area (`set_max_area 0.0`)
- Hold time fixing is enabled to ensure hold time constraints are met

## For Report Submission

Submit these four files:
1. `Group_39.Area`
2. `Group_39.Power`
3. `Group_39.TimingSetup`
4. `Group_39.TimingHold`

All files are generated in the current directory after running `./run_synthesis.sh`.

