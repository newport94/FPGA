vlib work
vmap work ./work
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../tb/tb_clk_div.vhd
vsim tb_clk_div