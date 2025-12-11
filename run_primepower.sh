#!/bin/bash

# ============================================================================
# Script: run_primepower.sh
# Description:
#   PrimeTime/PrimePower analysis script for M216A Delta-Sigma Modulator
#   
#   This script:
#     1. Sources the tool setup
#     2. Verifies required files exist (netlist, VCD)
#     3. Runs PrimeTime/PrimePower analysis
#     4. Generates timing and power reports
#     5. Validates results are in expected range
# ============================================================================

echo "========================================================"
echo "  M216A - PrimeTime/PrimePower Analysis"
echo "========================================================"
echo ""

# Source the tool setup to get PrimeTime in PATH
echo "[1/4] Sourcing tool setup..."
source tool-setup

# Check if gate-level netlist exists
echo "[2/4] Verifying required files..."
if [ ! -f M216A_TopModule.vg ]; then
    echo "ERROR: Gate-level netlist M216A_TopModule.vg not found!"
    echo "Please run synthesis first: ./run_synthesis.sh"
    exit 1
fi
echo "  ✓ M216A_TopModule.vg (gate-level netlist)"

# Check if VCD file exists
if [ ! -f M216A_TopModule.vcd ]; then
    echo "WARNING: VCD file M216A_TopModule.vcd not found!"
    echo "Running RTL simulation to generate VCD..."
    ./run_testbench.sh
    if [ ! -f M216A_TopModule.vcd ]; then
        echo "ERROR: Failed to generate VCD file!"
        exit 1
    fi
fi
echo "  ✓ M216A_TopModule.vcd (switching activity)"

# Run PrimeTime/PrimePower
echo "[3/4] Running PrimeTime/PrimePower analysis..."
echo ""
pt_shell -f Group_39_PrimeTimePower.tcl

# Check if analysis completed
if [ $? -eq 0 ]; then
    echo ""
    echo "[4/4] Analysis completed successfully!"
    echo ""
    echo "========================================================"
    echo "  Generated Reports:"
    echo "========================================================"
    
    # Timing reports
    if [ -f Group_39.TimingSetup ]; then
        lines=$(wc -l < Group_39.TimingSetup)
        echo "  ✓ Group_39.TimingSetup  ($lines lines)"
        # Extract worst slack
        slack=$(grep "slack (MET)" Group_39.TimingSetup | head -1 | awk '{print $(NF)}')
        if [ ! -z "$slack" ]; then
            echo "      Setup slack: $slack ns (MET)"
        fi
    else
        echo "  ✗ Group_39.TimingSetup  (NOT GENERATED)"
    fi
    
    if [ -f Group_39.TimingHold ]; then
        lines=$(wc -l < Group_39.TimingHold)
        echo "  ✓ Group_39.TimingHold   ($lines lines)"
        # Extract worst slack
        slack=$(grep "slack (MET)" Group_39.TimingHold | head -1 | awk '{print $(NF)}')
        if [ ! -z "$slack" ]; then
            echo "      Hold slack: $slack ns (MET)"
        fi
    else
        echo "  ✗ Group_39.TimingHold   (NOT GENERATED)"
    fi
    
    # Power report
    if [ -f Group_39.Power ]; then
        lines=$(wc -l < Group_39.Power)
        echo "  ✓ Group_39.Power        ($lines lines)"
        # Extract total power (in scientific notation, e.g., 1.362e-04)
        power_w=$(grep "Total Power" Group_39.Power | awk '{print $4}')
        if [ ! -z "$power_w" ]; then
            # Convert to µW using awk (handles scientific notation)
            power_uw=$(echo "$power_w" | awk '{printf "%.2f", $1 * 1000000}')
            echo "      Total power: ${power_uw} µW"
            
            # Check if in expected range (50-250 µW)
            in_range=$(echo "$power_uw" | awk '{if ($1 >= 50 && $1 <= 250) print "1"; else print "0"}')
            if [ "$in_range" = "1" ]; then
                echo "      ✓ Power is within expected range (50-250 µW)"
            else
                echo "      ⚠ WARNING: Power is outside expected range (50-250 µW)"
            fi
        fi
    else
        echo "  ✗ Group_39.Power        (NOT GENERATED)"
    fi
    
    echo ""
    echo "========================================================"
    echo "  Additional Reports (for debugging):"
    echo "========================================================"
    
    if [ -f Group_39.Power_verbose ]; then
        echo "  ✓ Group_39.Power_verbose  (detailed power breakdown)"
    fi
    
    if [ -f Group_39.Power_hier ]; then
        echo "  ✓ Group_39.Power_hier     (hierarchical power)"
    fi
    
    if [ -f Group_39.PT_constraints ]; then
        echo "  ✓ Group_39.PT_constraints (constraint violations)"
    fi
    
    echo ""
    echo "========================================================"
    echo "  Analysis complete!"
    echo "========================================================"
else
    echo ""
    echo "[4/4] ERROR: PrimeTime/PrimePower analysis failed!"
    echo ""
    echo "Check the output above for error messages"
    exit 1
fi

echo ""

