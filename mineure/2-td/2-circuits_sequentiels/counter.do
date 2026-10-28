quit -sim

vlib work

vcom counter.vhd
vcom counter_tb.vhd

vsim -c work.counter_tb 

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/i_clk
add wave -color green uut/i_en
add wave -color green uut/i_rst

# SIGNAUX INTERNES (L'état du compteur)
add wave -divider Internes:
add wave -color orange uut/r_count
add wave -color orange uut/s_carry

# OUTPUTS
add wave -divider Outputs:
add wave -color blue uut/o_count
add wave -color purple theoretical_output

run -all