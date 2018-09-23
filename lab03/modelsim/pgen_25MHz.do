vlib work
vmap work ./work
vcom -work work ../rtl/pgen_25MHz.vhd
vcom -work work ../tb/tb_pgen_25MHz.vhd
vsim tb_pgen_25MHz

add wave  \
sim:/tb_pgen_25mhz/UUT/i_clk \
sim:/tb_pgen_25mhz/UUT/i_rst \
sim:/tb_pgen_25mhz/UUT/o_pulse \
sim:/tb_pgen_25mhz/UUT/cntr \
sim:/tb_pgen_25mhz/UUT/synchReset

run 400 ns