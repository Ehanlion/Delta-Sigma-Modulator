################################################################################
# PRIMETIME: Static Timing Analysis Tool                                       #
################################################################################
remove_design -all

# Add search paths for ptpx to find our technology libs.
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCelltt0p8v25c.db"
set link_library   "* N16ADFP_StdCelltt0p8v25c.db"

# Read the gate-level verilog files
read_verilog {alu.vg}
set DESIGN_NAME alu
current_design $DESIGN_NAME
link_design $DESIGN_NAME

# Describe the clock waveform & setup operating conditions
set Tclk 8.0
set TCU  0.1
set IN_DEL 0.6
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk_p_i"]
create_clock -name "clk_p_i" -period $Tclk [get_ports "clk_p_i"]
set_clock_uncertainty $TCU [get_clocks "clk_p_i"]
set_propagated_clock clk_p_i
set_input_delay $IN_DEL -clock "clk_p_i" $ALL_IN_BUT_CLK
set_operating_conditions tt0p8v25c
report_timing -max_paths 2 -delay_type max -sort_by slack -nosplit -slack_lesser_than 1000
extract_model -library_cell -format lib -output $DESIGN_NAME

################################################################################
# PRIMEPOWER: Data-Dependent, Cycle-Accurate Power Analysis                    #
################################################################################

set power_enable_analysis true
set power_analysis_mode averaged
read_vcd alu.vcd -strip_path alu_tb/alu_0
update_power
report_power -verbose

# To exit post simulation
exit