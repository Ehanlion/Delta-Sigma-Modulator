################################################################################
# DESIGN COMPILER: Logic Synthesis Script for Group 39                        #
# Project: M216A Delta-Sigma Modulator                                         #
# Generates: Area, Power, TimingSetup, and TimingHold reports                 #
################################################################################

remove_design -all

# Add search paths for technology libraries
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCellss0p72v125c.db"
set link_library "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"

# Set min library for hold time analysis
set_min_library "N16ADFP_StdCellff0p88vm40c.db" -min_version "N16ADFP_StdCellss0p72v125c.db"

# Define work path (create WORK directory if it doesn't exist)
define_design_lib WORK -path ./WORK
set alib_library_analysis_path "./alib-52/"

# Read all verilog source files for the design
# Order matters: sub-modules first, then top module
analyze -format verilog {mash_stage.v}
analyze -format verilog {noise_shaper.v}
analyze -format verilog {M216A_TopModule.v}

# Set design name and elaborate
set DESIGN_NAME M216A_TopModule

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link

# Set operating conditions (min/max for corner analysis)
set_operating_conditions -min ff0p88vm40c -max ss0p72v125c

################################################################################
# TIMING CONSTRAINTS                                                           #
################################################################################

# Clock configuration for 500 MHz (2.0 ns period)
set Tclk 2.0
set TCU  0.05
set IN_DEL 0.4
set IN_DEL_MIN 0.2
set OUT_DEL 0.4
set OUT_DEL_MIN 0.2

# Get all inputs except clock
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]

# Create clock constraint
create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_fix_hold clk
set_dont_touch_network [get_clocks "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]

# Set input/output delays
set_input_delay $IN_DEL -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk" [all_outputs]

# Minimize area
set_max_area 0.0

################################################################################
# COMPILATION                                                                  #
################################################################################

# Flatten hierarchy for optimization
ungroup -flatten -all
uniquify

# Multi-step compilation for best results
compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

################################################################################
# REPORT GENERATION                                                            #
################################################################################

# Generate Setup Timing Report
report_timing -path full -delay max -max_paths 10 -nworst 2 > Group_39.TimingSetup

# Generate Hold Timing Report
report_timing -path full -delay min -max_paths 10 -nworst 2 > Group_39.TimingHold

# Generate Area Report
report_area -hierarchy > Group_39.Area

# Generate Power Report
report_power -hier -hier_level 2 > Group_39.Power

# Additional reports for debugging (optional)
report_resources > Group_39.resources
report_constraint -verbose > Group_39.constraint
check_design > Group_39.check_design
check_timing > Group_39.check_timing

################################################################################
# OUTPUT FILES                                                                 #
################################################################################

# Write synthesized netlist
write -hierarchy -format verilog -output ${DESIGN_NAME}.vg

# Write timing information
write_sdf -version 1.0 -context verilog ${DESIGN_NAME}.sdf

# Write constraints for back-annotation
set_propagated_clock [all_clocks]
write_sdc ${DESIGN_NAME}.sdc

################################################################################
# SUMMARY                                                                      #
################################################################################

puts ""
puts "========================================================"
puts "  SYNTHESIS COMPLETE - GROUP 39"
puts "========================================================"
puts "  Design: $DESIGN_NAME"
puts "  Clock Period: ${Tclk} ns (500 MHz)"
puts ""
puts "  Generated Reports:"
puts "    - Group_39.Area"
puts "    - Group_39.Power"
puts "    - Group_39.TimingSetup"
puts "    - Group_39.TimingHold"
puts ""
puts "  Generated Files:"
puts "    - ${DESIGN_NAME}.vg (gate-level netlist)"
puts "    - ${DESIGN_NAME}.sdf (timing delays)"
puts "    - ${DESIGN_NAME}.sdc (timing constraints)"
puts "========================================================"
puts ""

# Exit dc_shell
exit

