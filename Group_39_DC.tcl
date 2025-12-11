################################################################################
# Design Compiler Power Analysis (for comparison with PrimePower)
# Reads existing gate-level netlist and generates DC power estimate
################################################################################

remove_design -all

# Technology libraries
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCellss0p72v125c.db"
set link_library "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"

# Read existing gate-level netlist
read_verilog {M216A_TopModule.vg}
set DESIGN_NAME M216A_TopModule
current_design $DESIGN_NAME
link

# Operating conditions
set_operating_conditions -min ff0p88vm40c -max ss0p72v125c

# Clock and timing constraints (500 MHz)
set Tclk 2.0
set TCU  0.05
set IN_DEL 0.4
set IN_DEL_MIN 0.2
set OUT_DEL 0.4
set OUT_DEL_MIN 0.2

set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]
create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_fix_hold clk
set_dont_touch_network [get_clocks "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]

set_input_delay $IN_DEL -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk" [all_outputs]

# Generate reports with DC prefix (verbose format)
report_timing -path full -delay max -max_paths 10 -nworst 2 > Group_39_DC.TimingSetup
report_timing -path full -delay min -max_paths 10 -nworst 2 > Group_39_DC.TimingHold
report_area -hierarchy > Group_39_DC.Area
report_power -verbose > Group_39_DC.Power

puts ""
puts "========================================================"
puts " Design Compiler Power Analysis Complete"
puts "========================================================"
puts "  Method: Statistical (no VCD)"
puts "  Output: Group_39_DC.Power"
puts "========================================================"
puts ""

exit

