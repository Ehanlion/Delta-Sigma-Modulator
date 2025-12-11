#!/bin/bash

# ============================================================================
# Script: run_synthesis.sh
# ============================================================================

echo "========================================================"
echo "  Group 39 - M216A Delta-Sigma Modulator Synthesis"
echo "========================================================"
echo ""

# Source the tool setup to get Synopsys tools in PATH
echo "[1/4] Sourcing tool setup..."
source tool-setup

# Create work directory for Design Compiler if it doesn't exist
echo "[2/4] Setting up work directories..."
if [ ! -d WORK ]; then
    echo "  - Creating WORK directory..."
    mkdir WORK
else
    echo "  - WORK directory exists"
fi

# Create alib directory for compiled libraries
if [ ! -d alib-52 ]; then
    echo "  - Creating alib-52 directory..."
    mkdir alib-52
else
    echo "  - alib-52 directory exists"
fi

# Run Design Compiler with the synthesis script
echo "[3/4] Running Design Compiler..."
echo "  - Design: M216A_TopModule"
echo "  - Clock: 500 MHz (2.0 ns period)"
echo ""

# Actually boot dc_shell and run the synthesis script
dc_shell -f Group_39.tcl

# Check if synthesis completed successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "[4/4] Synthesis completed successfully!"
    echo ""
    echo "========================================================"
    echo "  Generated Reports:"
    echo "========================================================"
    
    # Check and display file sizes for generated reports
    if [ -f Group_39.Area ]; then
        size=$(wc -l < Group_39.Area)
        echo "  + Group_39.Area         ($size lines)"
    else
        echo "  x Group_39.Area         (NOT GENERATED)"
    fi
    
    if [ -f Group_39.Power ]; then
        size=$(wc -l < Group_39.Power)
        echo "  + Group_39.Power        ($size lines, verbose)"
    else
        echo "  x Group_39.Power        (NOT GENERATED)"
    fi
    
    if [ -f Group_39.TimingSetup ]; then
        size=$(wc -l < Group_39.TimingSetup)
        echo "  + Group_39.TimingSetup  ($size lines)"
    else
        echo "  x Group_39.TimingSetup  (NOT GENERATED)"
    fi
    
    if [ -f Group_39.TimingHold ]; then
        size=$(wc -l < Group_39.TimingHold)
        echo "  + Group_39.TimingHold   ($size lines)"
    else
        echo "  x Group_39.TimingHold   (NOT GENERATED)"
    fi
    
    echo ""
    if [ -f M216A_TopModule.vg ]; then
        echo "  + M216A_TopModule.vg    (gate-level netlist)"
    fi
    
    if [ -f M216A_TopModule.sdf ]; then
        echo "  + M216A_TopModule.sdf   (timing delays)"
    fi
    
    if [ -f M216A_TopModule.sdc ]; then
        echo "  + M216A_TopModule.sdc   (timing constraints)"
    fi
    echo ""
else
    echo ""
    echo "[4/4] ERROR: Synthesis failed!"
    echo ""
    exit 1
fi

