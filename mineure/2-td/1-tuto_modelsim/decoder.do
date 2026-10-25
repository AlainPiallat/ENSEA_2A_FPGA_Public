quit -sim

vlib work

vcom decoder.vhd
vcom decoder_tb.vhd

vsim -c work.decoder_tb

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/data_in

# OUTPUTS
add wave -divider Outputs:
add wave uut/data_out

run -all