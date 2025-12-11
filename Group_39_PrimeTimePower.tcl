################################################################################
# Group_39_PrimeTimePower.tcl
# PrimeTime / PrimePower script for M216A_TopModule
################################################################################

################################################################################
# PRIMETIME: Static Timing Analysis Tool
################################################################################

remove_design -all

# Libraries and search path (match Group_39.tcl)
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCellss0p72v125c.db"
set link_library   "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db"

# Read the gate-level netlist from DC
read_verilog {M216A_TopModule.vg}
set DESIGN_NAME M216A_TopModule
current_design $DESIGN_NAME
link_design    $DESIGN_NAME

# ---------------------------------------------------------------------------
# Timing constraints (copied from Group_39.tcl, HW3 style)
# ---------------------------------------------------------------------------
set Tclk       2.0     ;# 500 MHz
set TCU        0.025
set IN_DEL     0.4
set IN_DEL_MIN 0.2
set OUT_DEL    0.4
set OUT_DEL_MIN 0.2

# All inputs except the clock
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]

# Create clock on port "clk"
create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]

# Treat this as a propagated clock (like in HW3)
set_propagated_clock clk

# Input delays
set_input_delay      $IN_DEL      -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN  -clock "clk" $ALL_IN_BUT_CLK

# Output delays
set_output_delay      $OUT_DEL      -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN  -clock "clk" [all_outputs]

# Operating condition (match Group_39.tcl max corner)
set_operating_conditions ss0p72v125c

# ---------------------------------------------------------------------------
# Static timing analysis (setup & hold) – HW3-style, multiple paths
# ---------------------------------------------------------------------------
update_timing

# Setup timing (max delay) – HW3 style: multiple paths, sorted by slack
report_timing \
    -max_paths 10 \
    -delay_type max \
    -sort_by slack \
    -nosplit \
    -slack_lesser_than 1000 \
    > Group_39.TimingSetup

# Hold timing (min delay) – same options, just min delay
report_timing \
    -max_paths 10 \
    -delay_type min \
    -sort_by slack \
    -nosplit \
    -slack_lesser_than 1000 \
    > Group_39.TimingHold

# Optional constraint summary (for you, not required to submit)
report_constraints -all_violators > Group_39.PT_constraints


################################################################################
# PRIMEPOWER: Averaged Power Analysis (HW3-style)
################################################################################

# Enable power analysis engine
set power_enable_analysis true

# Use averaged power (same style as HW3)
set power_analysis_mode averaged

# Read switching activity from VCD file
# The VCD is generated from RTL simulation with testbench top: EE216A_Testbench
# DUT instance name: "dut"
# 
# Note: The RTL VCD has different internal hierarchy than the flattened gate-level
# netlist, so we can only reliably annotate top-level port activity.
# PrimePower will propagate activity internally.
if { [file exists "M216A_TopModule.vcd"] } {
    puts "Reading VCD: M216A_TopModule.vcd"
    # VCD timescale is 1ps, time units in VCD are picoseconds
    # Read VCD and specify time range: start at 20ns (20000ps) to skip reset
    read_vcd M216A_TopModule.vcd -strip_path EE216A_Testbench/dut -time {20000 100000000}
} else {
    puts "WARNING: VCD file M216A_TopModule.vcd not found. Power will be vectorless."
}

# Update power engine after VCD is loaded
update_power

# Total power report (the one you will submit)
report_power > Group_39.Power

# Optional detailed/hierarchical power for debugging
report_power -verbose             > Group_39.Power_verbose
report_power -hierarchy -levels 2 > Group_39.Power_hier

################################################################################
# Summary
################################################################################

puts ""
puts "========================================================"
puts " PrimeTime / PrimePower Complete - GROUP 39"
puts "--------------------------------------------------------"
puts "  Design:         $DESIGN_NAME"
puts "  Timing reports:"
puts "    Group_39.TimingSetup  (setup timing, multiple paths)"
puts "    Group_39.TimingHold   (hold timing, multiple paths)"
puts "  Power report:"
puts "    Group_39.Power        (averaged power, with VCD if available)"
puts "========================================================"
puts ""

exit
