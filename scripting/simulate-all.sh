#!/bin/bash
source tool-setup
vlib work
vmap work work
vlog alu.vg 
vlog alu_tb.v 
vlog N16ADFP_StdCell.v
vsim -c alu_tb -do "run -all; quit"
source tool-setup
pt_shell -f PrimeTime_PrimePower.tcl