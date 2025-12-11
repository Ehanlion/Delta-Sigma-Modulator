################################################################################
# Group_39_PrimeTimePower.tcl
# PrimeTime/PrimePower Analysis for M216A Delta-Sigma Modulator
################################################################################

remove_design -all

################################################################################
# SETUP: Libraries and Design
################################################################################

# Technology libraries (match synthesis script)
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCellss0p72v125c.db"
set link_library   "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db"

# Read gate-level netlist from synthesis
read_verilog {M216A_TopModule.vg}
set DESIGN_NAME M216A_TopModule
current_design $DESIGN_NAME
link_design    $DESIGN_NAME

################################################################################
# TIMING: Constraints and Analysis
################################################################################

# Clock and timing parameters (500 MHz) - match synthesis script
set Tclk       2.0
set TCU        0.025
set IN_DEL     0.4
set IN_DEL_MIN 0.2
set OUT_DEL    0.4
set OUT_DEL_MIN 0.2

# Clock definition
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]
create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]
set_propagated_clock clk

# I/O delays
set_input_delay      $IN_DEL      -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN  -clock "clk" $ALL_IN_BUT_CLK
set_output_delay      $OUT_DEL      -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN  -clock "clk" [all_outputs]

# Operating conditions (slow corner for max delay)
set_operating_conditions ss0p72v125c

# Run timing analysis
update_timing
report_timing -max_paths 10 -delay_type max -sort_by slack -nosplit \
    -slack_lesser_than 1000 > Group_39_Prime.TimingSetup
report_timing -max_paths 10 -delay_type min -sort_by slack -nosplit \
    -slack_lesser_than 1000 > Group_39_Prime.TimingHold

################################################################################
# POWER: PrimePower Analysis with VCD
################################################################################

# Enable PrimePower engine
set power_enable_analysis true
set power_analysis_mode averaged

# Read VCD switching activity from RTL simulation
# This improves power estimation by excluding reset transients:
#    (add to read_vc if you want) ... -time {20000 100000000}
if { [file exists "M216A_TopModule.vcd"] } {
    puts "Reading VCD: M216A_TopModule.vcd"
    read_vcd M216A_TopModule.vcd -strip_path EE216A_Testbench/dut
} else {
    puts "WARNING: VCD file not found. Running vectorless power analysis."
}

# Calculate power with VCD annotation
update_power

# Generate power reports
report_power -verbose > Group_39_Prime.Power
report_power -hierarchy -levels 2 > Group_39_Prime.PowerHeirarchy

puts ""
puts "  Timing: Group_39_Prime.TimingSetup/Hold"
puts "  Power:  Group_39_Prime.Power"
puts "  Area:   Group_39_Prime.Area"
puts ""

exit
