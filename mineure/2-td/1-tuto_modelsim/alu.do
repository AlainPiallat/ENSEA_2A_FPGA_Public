quit -sim

vlib work

vcom alu.vhd
vcom alu_tb.vhd

vsim -c work.alu_tb

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/data_in0
add wave -color green uut/data_in1
add wave -color blue uut/sel

# OUTPUTS
add wave -divider Outputs:
add wave -color purple uut/data_out
add wave -color cyan theoretical_out

run -all