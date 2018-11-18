vlib work
vmap work ./work
vcom -work work ../rtl/piso.vhd
vcom -work work ../tb/tb_piso.vhd
vsim tb_piso

quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_piso/U_UUT/i_clk
add wave -noupdate /tb_piso/U_UUT/i_rst
add wave -noupdate /tb_piso/U_UUT/i_din
add wave -noupdate /tb_piso/U_UUT/i_mode
add wave -noupdate /tb_piso/U_UUT/o_sdout
add wave -noupdate /tb_piso/U_UUT/q_sr

run 800ns