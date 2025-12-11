#!/bin/bash

################################################################################
# run_dc.sh
# Design Compiler power analysis (statistical, no VCD required)
################################################################################

echo "========================================================"
echo "  Design Compiler Power Analysis"
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

# Run Design Compiler
echo "Running dc_shell..."
dc_shell -f Group_39_DC.tcl

# Check results
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================"
    echo "  Generated Files:"
    echo "========================================================"
    
    [ -f Group_39_DC.Power ] && echo "  + Group_39_DC.Power"
    [ -f Group_39_DC.TimingSetup ] && echo "  + Group_39_DC.TimingSetup"
    [ -f Group_39_DC.TimingHold ] && echo "  + Group_39_DC.TimingHold"
    [ -f Group_39_DC.Area ] && echo "  + Group_39_DC.Area"
    
    echo "========================================================"
    echo ""
else
    echo ""
    echo "ERROR: Analysis failed!"
    echo "Check dc_power.log for details"
    exit 1
fi

