vlib work
vmap work ./work
vcom -work work ../rtl/sipo.vhd
vcom -work work ../tb/tb_sipo.vhd
vsim tb_sipo

quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sipo/U_UUT/i_clk
add wave -noupdate /tb_sipo/U_UUT/i_rst
add wave -noupdate /tb_sipo/U_UUT/i_sin
add wave -noupdate /tb_sipo/U_UUT/i_en
add wave -noupdate /tb_sipo/U_UUT/o_pout
add wave -noupdate /tb_sipo/U_UUT/o_vld 
add wave -noupdate /tb_sipo/U_UUT/q_cntr
add wave -noupdate /tb_sipo/U_UUT/q_temp

run 200 ns