#!/bin/bash

# Setup variables for files names
Prefix="Group_39"
Area="Area"
Power="Power"
Hold="TimingHold"
Setup="TimingSetup"

# Read the Area
echo "------------------------------------------------"
echo "Area Results from Group_39.Area"
echo "------------------------------------------------"
cat $Prefix.$Area | grep "Total"

# Read the power
echo "------------------------------------------------"
echo "Power Results from Group_39.Power"
echo "------------------------------------------------"
cat $Prefix.$Power | grep "M216A_TopModule"

# Read the hold timing
echo "------------------------------------------------"
echo "Hold Timing Results from Group_39.TimingHold"
echo "------------------------------------------------"
cat $Prefix.$Hold | grep "slack"

# Read the setup timing
echo "------------------------------------------------"
echo "Setup Timing Results from Group_39.TimingSetup"
echo "------------------------------------------------"
cat $Prefix.$Setup | grep "slack"