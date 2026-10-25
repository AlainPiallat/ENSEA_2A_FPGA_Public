quit -sim

vlib work

vcom multiplexer.vhd
vcom multiplexer_tb.vhd

vsim -c work.multiplexer_tb

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/in0
add wave -color green uut/in1
add wave -color blue uut/sel

# OUTPUTS
add wave -divider Outputs:
add wave -color purple uut/data_out
add wave -color cyan theoretical_out

run -all