#!/bin/bash

################################################################################
# run_primepower.sh
# PrimeTime/PrimePower analysis with VCD (accurate power)
################################################################################

echo "========================================================"
echo "  PrimeTime/PrimePower Analysis"
echo "========================================================"
echo ""

# Source tool setup
source tool-setup

# Check for gate-level netlist
if [ ! -f M216A_TopModule.vg ]; then
    echo "ERROR: Gate-level netlist not found!"
    echo "Run synthesis first: ./run_synthesis.sh"
    exit 1
fi

# Check for VCD file
if [ ! -f M216A_TopModule.vcd ]; then
    echo "VCD file not found. Running testbench..."
    ./run_testbench.sh
    if [ ! -f M216A_TopModule.vcd ]; then
        echo "ERROR: Failed to generate VCD!"
        exit 1
    fi
fi

# Run PrimeTime/PrimePower
echo "Running pt_shell..."
pt_shell -f Group_39_PrimeTimePower.tcl

# Check results
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================"
    echo "  Generated Files:"
    echo "========================================================"
    
    [ -f Group_39_Prime.Power ] && echo "  + Group_39_Prime.Power"
    [ -f Group_39_Prime.TimingSetup ] && echo "  + Group_39_Prime.TimingSetup"
    [ -f Group_39_Prime.TimingHold ] && echo "  + Group_39_Prime.TimingHold"
    [ -f Group_39_Prime.Area ] && echo "  + Group_39_Prime.Area"
    
    echo "========================================================"
    echo ""
else
    echo ""
    echo "ERROR: Analysis failed!"
    echo "Check pt_power.log for details"
    exit 1
fi