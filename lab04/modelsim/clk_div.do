vlib work
vmap work ./work
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../tb/tb_clk_div.vhd
vsim tb_clk_div

add wave -noupdate /tb_clk_div/u_UUT/o_clk_div
add wave -noupdate /tb_clk_div/u_UUT/i_clk
add wave -noupdate /tb_clk_div/u_UUT/i_reset
add wave -noupdate /tb_clk_div/u_UUT/w_clk_temp
add wave -noupdate /tb_clk_div/u_UUT/cntr
add wave -noupdate /tb_clk_div/u_UUT/w_max_cnt

run 2 us