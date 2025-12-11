#!/bin/bash

# Setup variables for file names
Prefix="Group_39"
Area="Area"
Power="Power"
Hold="TimingHold"
Setup="TimingSetup"

# Create results directory if it doesn't exist
mkdir -p results

# Find the next available results file number
counter=1
while [ -f "results/deltaSigmaResults${counter}.txt" ]; do
    counter=$((counter + 1))
done
OUTPUT_FILE="results/deltaSigmaResults${counter}.txt"

# Start writing to output file
{   
    # Extract Power Results (verbose format)
    echo "========================================================"
    echo "                  POWER RESULTS"
    echo "========================================================"
    echo ""
    
    # Extract dynamic power breakdown
    echo "Dynamic Power Breakdown:"
    echo "------------------------"
    grep "Cell Internal Power" $Prefix.$Power | head -1
    grep "Net Switching Power" $Prefix.$Power | head -1
    grep "Total Dynamic Power" $Prefix.$Power | head -1
    echo ""
    
    # Extract leakage power
    grep "Cell Leakage Power" $Prefix.$Power | head -1
    echo ""
    
    # Extract power by group (verbose format table)
    echo "Power by Component Group:"
    echo "-------------------------"
    awk '/Power Group/,/^Total/ {print}' $Prefix.$Power | head -10
    echo ""

    # Get the total power as well
    echo "Total Power:"
    echo "-------------------------"
    grep "Total" $Prefix.$Power
    echo ""
    
    # Extract Area Results
    echo "========================================================"
    echo "                   AREA RESULTS"
    echo "========================================================"
    echo ""
    grep -E "Combinational area:|Buf/Inv area:|Noncombinational area:|Macro/Black Box area:|Total cell area:" $Prefix.$Area | \
    awk '{
        if ($1 == "Combinational") printf "%-30s %15s\n", "Combinational area:", $3;
        else if ($1 == "Buf/Inv") printf "%-30s %15s\n", "Buf/Inv area:", $3;
        else if ($1 == "Noncombinational") printf "%-30s %15s\n", "Noncombinational area:", $3;
        else if ($1 == "Macro/Black") printf "%-30s %15s\n", "Macro/Black Box area:", $4;
        else if ($1 == "Total" && $2 == "cell") printf "%-30s %15s\n", "Total cell area:", $4;
    }'
    echo ""
    
    # Extract Setup Timing Results
    echo "========================================================"
    echo "              SETUP TIMING RESULTS"
    echo "========================================================"
    echo ""
    echo "Critical Path Slacks (MET indicates timing constraint met):"
    echo ""
    awk '/Endpoint:/ {endpoint=$2" "$3} /slack/ {print "  " endpoint " -> Slack: " $3 " " $4}' $Prefix.$Setup
    echo ""
    
    # Extract Hold Timing Results
    echo "========================================================"
    echo "               HOLD TIMING RESULTS"
    echo "========================================================"
    echo ""
    echo "Critical Path Slacks (MET indicates timing constraint met):"
    echo ""
    awk '/Endpoint:/ {endpoint=$2" "$3} /slack/ {print "  " endpoint " -> Slack: " $3 " " $4}' $Prefix.$Hold
    echo ""
    
    echo "========================================================"
    echo "                   END OF REPORT"
    echo "========================================================"
    
} > "$OUTPUT_FILE"

echo "Results saved to: $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"