#!/bin/bash

# ============================================================================
# Script: run_mash_stage_tb.sh
# Description:
#   Headless ModelSim simulation script for mash_stage module testing
#   
#   This script:
#     1. Sources the tool setup
#     2. Creates/cleans the work library
#     3. Compiles mash_stage.v and mash_stage_tb.v
#     4. Runs the testbench in command-line mode
#     5. Displays results to console
# ============================================================================

echo "========================================================"
echo "  MASH Stage Module - ModelSim Simulation"
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
vlog -work work mash_stage.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of mash_stage.v failed!"
    exit 1
fi

vlog -work work mash_stage_tb.v
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation of mash_stage_tb.v failed!"
    exit 1
fi

echo "  - All files compiled successfully!"

# Run simulation in command-line mode
echo "[4/4] Running testbench..."
echo ""
vsim -c -do "run -all; quit" work.mash_stage_tb

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

