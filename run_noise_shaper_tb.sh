#!/bin/bash

# ============================================================================
# Script: run_noise_shaper_tb.sh
# ============================================================================

echo "========================================================"
echo "  Noise Shaper Module - ModelSim Simulation"
echo "========================================================"
echo ""

# Source the tool setup to get ModelSim in PATH
echo "[1/4] Sourcing tool setup..."
source tool-setup

# Clean and create work library
echo "[2/4] Setting up work library..."
if [ -d work ]; then
    echo "  - Removing existing work library..."
    vdel -lib work -all
fi
vlib work
vmap work work

# Compile Verilog files
echo "[3/4] Compiling Verilog files..."
vlog -work work noise_shaper.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of noise_shaper.v failed!"
    exit 1
fi

vlog -work work noise_shaper_tb.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of noise_shaper_tb.v failed!"
    exit 1
fi

echo "  - All files compiled successfully!"

# Run simulation in command-line mode
echo "[4/4] Running testbench..."
echo ""
vsim -c -do "run -all; quit" work.noise_shaper_tb

# Check if simulation completed
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================"
    echo "  Simulation completed!"
    echo "========================================================"
else
    echo ""
    echo "ERROR: Simulation failed!"
    exit 1
fi

