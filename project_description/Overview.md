# M216A Delta-Sigma Modulator Project Overview

## Project Goal
The goal of this project is to design, verify, and synthesize a **MASH 1-1-1 Delta-Sigma Modulator**. This architecture is commonly used in fractional-N frequency synthesizers to achieve fine frequency resolution with noise shaping.

## Core Functionality
The modulator takes an input divide ratio consisting of an integer part (`in_i`) and a fractional part (`in_f`). It produces a stream of integer divide values (`out`) whose average over time equals `in_i + in_f/2^16`.

### Key Features
- **Input**: 
  - `in_i`: 4-bit integer part (valid range 3-11).
  - `in_f`: 16-bit fractional part (0-65535).
- **Output**: `out` (4-bit integer).
- **Clock**: 500 MHz system clock.
- **Architecture**: 3-stage MASH 1-1-1 structure with a Noise Shaper.

## Directory Structure
- `deltaSigmaProject/`
  - `trainingProject/FinalProject/`: Contains the source code and scripts.
    - `M216A_TopModule.v`: Top-level module.
    - `mash_stage.v`: Single stage of the modulator.
    - `noise_shaper.v`: Noise shaping logic.
    - `M216A_Testbench.v`: Verification environment.
    - `DC_Synthesis.tcl`: Synthesis script.
    - `PrimeTime_PrimePower.tcl`: Power analysis script.

