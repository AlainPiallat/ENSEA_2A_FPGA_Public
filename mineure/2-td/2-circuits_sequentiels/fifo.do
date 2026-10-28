quit -sim

vlib work

vcom fifo.vhd
vcom fifo_tb.vhd

vsim -c work.fifo_tb 

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/fifo_i_clk
add wave -color green uut/fifo_i_d
add wave -color green uut/fifo_i_en

# SIGNAUX INTERNES (L'état de la file)
add wave -divider Internes:
add wave -color orange uut/fifo_r_q(1)
add wave -color orange uut/fifo_r_q(2)
add wave -color orange uut/fifo_r_q(3)
add wave -color orange uut/fifo_r_q(4)

# OUTPUTS
add wave -divider Outputs:
add wave -color blue uut/fifo_o_q
add wave -color purple theoretical_output

run -all