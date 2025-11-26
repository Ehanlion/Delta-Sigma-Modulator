################################################################################
# DESIGN COMPILER:  Logic Synthesis for MASH 1-1-1 Project
################################################################################

remove_design -all

# ------------------------------------------------------------------------------
#  Library setup (same as HW3)
# ------------------------------------------------------------------------------

set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library      "N16ADFP_StdCellss0p72v125c.db"
set link_library        "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db dw_foundation.sldb"
set synthetic_library   "dw_foundation.sldb"

set_min_library "N16ADFP_StdCellff0p88vm40c.db" -min_version "N16ADFP_StdCellss0p72v125c.db"

# Define work library (folder WORK must already exist)
define_design_lib WORK -path ./WORK
set alib_library_analysis_path "./alib-52/"

# ------------------------------------------------------------------------------
#  Design setup
# ------------------------------------------------------------------------------

# Top-level design name
set DESIGN_NAME  M216A_TopModule

# Group name for report filenames
set GROUP_NAME   Group_39

# Read RTL files
analyze -format verilog {mash_stage.v noise_shaper.v M216A_TopModule.v}

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link

# ------------------------------------------------------------------------------
#  Operating conditions
# ------------------------------------------------------------------------------

set_operating_conditions -min ff0p88vm40c -max ss0p72v125c

# ------------------------------------------------------------------------------
#  Clock and I/O constraints
#   - 500 MHz clock --> 2 ns period
#   - Clock port: clk
# ------------------------------------------------------------------------------

set Tclk       2.0
set TCU        0.1
set IN_DEL     0.3
set IN_DEL_MIN 0.1
set OUT_DEL    0.3
set OUT_DEL_MIN 0.1

set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]

create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_fix_hold clk
set_dont_touch_network [get_clocks "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]

set_input_delay  $IN_DEL     -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk" $ALL_IN_BUT_CLK

set_output_delay  $OUT_DEL     -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk" [all_outputs]

set_max_area 0.0

# ------------------------------------------------------------------------------
#  Flatten + uniquify
# ------------------------------------------------------------------------------

ungroup -flatten -all
uniquify

# ------------------------------------------------------------------------------
#  Compile
# ------------------------------------------------------------------------------

compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

# ------------------------------------------------------------------------------
#  Reports
# ------------------------------------------------------------------------------

report_timing  -path full -delay min -max_paths 10 -nworst 2  > ${GROUP_NAME}.TimingHold
report_timing  -path full -delay max -max_paths 10 -nworst 2  > ${GROUP_NAME}.TimingSetup

report_area -hierarchy                                    > ${GROUP_NAME}.Area
report_power -hier -hier_level 2                          > ${GROUP_NAME}.Power
report_resources                                          > ${GROUP_NAME}.Resources
report_constraint -verbose                                > ${GROUP_NAME}.Constraint
check_design                                              > ${GROUP_NAME}.CheckDesign
check_timing                                              > ${GROUP_NAME}.CheckTiming

# ------------------------------------------------------------------------------
#  Output files
# ------------------------------------------------------------------------------

write -hierarchy -format verilog -output ${DESIGN_NAME}.vg
write_sdf -version 1.0 -context verilog ${DESIGN_NAME}.sdf

set_propagated_clock [all_clocks]
write_sdc ${DESIGN_NAME}.sdc

################################################################################
# End of Group_39.tcl
################################################################################
