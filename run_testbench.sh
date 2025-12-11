#!/bin/bash

# ============================================================================
# Script: run_testbench.sh
# ============================================================================

echo "========================================================"
echo "  M216A Delta-Sigma Modulator - ModelSim Simulation"
echo "========================================================"
echo ""

# Source the tool setup to get ModelSim in PATH
echo "[1/5] Sourcing tool setup..."
source tool-setup

# Clean and create work library
echo "[2/5] Setting up work library..."
if [ -d work ]; then
    echo "  - Removing existing work library..."
    vdel -lib work -all
fi
vlib work
vmap work work

# Compile all Verilog source files
echo "[3/5] Compiling Verilog files..."
vlog -work work mash_stage.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of mash_stage.v failed!"
    exit 1
fi

vlog -work work noise_shaper.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of noise_shaper.v failed!"
    exit 1
fi

vlog -work work M216A_TopModule.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of M216A_TopModule.v failed!"
    exit 1
fi

vlog -work work EE216A_Testbench.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of EE216A_Testbench.v failed!"
    exit 1
fi

echo "  - All files compiled successfully!"

# Run simulation in command-line mode
echo "[4/5] Running testbench..."
echo ""
vsim -c -do "run -all; quit" work.EE216A_Testbench

# Check if simulation completed
if [ $? -eq 0 ]; then
    echo ""
    echo "[5/5] Simulation completed successfully!"
    echo ""
    echo "Generated vcd file: M216A_TopModule.vcd"
    echo ""
else
    echo ""
    echo "[5/5] ERROR: Simulation failed!"
    exit 1
fi

