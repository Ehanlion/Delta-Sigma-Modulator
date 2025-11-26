###################################################################

# Created by write_sdc on Sun Nov 23 16:32:35 2025

###################################################################
set sdc_version 2.2

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max ss0p72v125c -max_library                         \
N16ADFP_StdCellss0p72v125c\
                         -min ff0p88vm40c -min_library                         \
N16ADFP_StdCellff0p88vm40c
set_max_area 0
create_clock [get_ports clk]  -period 2  -waveform {0 1}
set_clock_uncertainty 0.1  [get_clocks clk]
set_propagated_clock [get_clocks clk]
set_input_delay -clock clk  -max 0.3  [get_ports rst_n]
set_input_delay -clock clk  -min 0.1  [get_ports rst_n]
set_input_delay -clock clk  -max 0.3  [get_ports {in_i[3]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_i[3]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_i[2]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_i[2]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_i[1]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_i[1]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_i[0]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_i[0]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[15]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[15]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[14]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[14]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[13]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[13]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[12]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[12]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[11]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[11]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[10]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[10]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[9]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[9]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[8]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[8]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[7]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[7]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[6]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[6]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[5]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[5]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[4]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[4]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[3]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[3]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[2]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[2]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[1]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[1]}]
set_input_delay -clock clk  -max 0.3  [get_ports {in_f[0]}]
set_input_delay -clock clk  -min 0.1  [get_ports {in_f[0]}]
set_output_delay -clock clk  -max 0.3  [get_ports {out[3]}]
set_output_delay -clock clk  -min 0.1  [get_ports {out[3]}]
set_output_delay -clock clk  -max 0.3  [get_ports {out[2]}]
set_output_delay -clock clk  -min 0.1  [get_ports {out[2]}]
set_output_delay -clock clk  -max 0.3  [get_ports {out[1]}]
set_output_delay -clock clk  -min 0.1  [get_ports {out[1]}]
set_output_delay -clock clk  -max 0.3  [get_ports {out[0]}]
set_output_delay -clock clk  -min 0.1  [get_ports {out[0]}]
