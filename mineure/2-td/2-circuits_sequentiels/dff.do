quit -sim

vlib work

vcom dff.vhd
vcom dff_tb.vhd

vsim -c work.dff_tb 

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color green uut/i_d
add wave -color green uut/i_en

# OUTPUTS
add wave -divider Outputs:
add wave -color blue uut/o_q
add wave -color purple theoretical_q

run -all