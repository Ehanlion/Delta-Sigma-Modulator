transcript on

;# clean or make the work library
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work

;# compile RTL + TB
vlog -sv -work work HW2_alu.v HW2_test_alu.v

;# elaborate the TESTBENCH
vsim -quiet work.HW2_test_alu

;# waves and run
radix -hex
add wave -r /*
restart -force
run -all
