#!/bin/bash

################################################################################
# Cleanup script for removing power, timing, area files
################################################################################

# Remove power, timing, area files
rm -f -v Group_39_DC.Power
rm -f -v Group_39_DC.TimingSetup
rm -f -v Group_39_DC.TimingHold
rm -f -v Group_39_DC.Area

# Remove PrimeTime/PrimePower files
rm -f -v Group_39_Prime.Power
rm -f -v Group_39_Prime.TimingSetup
rm -f -v Group_39_Prime.TimingHold
rm -f -v Group_39_Prime.Area
rm -f -v Group_39_Prime.PowerHeirarchy

# Remove standard files
rm -f -v Group_39.Power
rm -f -v Group_39.TimingSetup
rm -f -v Group_39.TimingHold
rm -f -v Group_39.Area
rm -f -v *.check_design
rm -f -v *.check_timing
rm -f -v *.constraint
rm -f -v *.resources
rm -f -v *.svf

# Remove VCD file
rm -f -v M216A_TopModule.vcd
rm -f -v M216A_TopModule.vg
rm -f -v M216A_TopModule.sdf
rm -f -v M216A_TopModule.sdc

# Remove logs
rm -f -v *.log
rm -f -v *.nfs*