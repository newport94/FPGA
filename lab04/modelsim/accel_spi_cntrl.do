# cd C:/Users/Ryan/Documents/repos/FPGA/lab04/modelsim

quit -sim

vlib work
vmap work ./work
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../rtl/accel_spi_rw2.vhd
vcom -work work ../rtl/accel_spi_cntrl.vhd
vcom -work work ../tb/acl_model_v2.vhd
vcom -work work ../tb/accel_spi_cntrl_tb.vhd
vsim accel_spi_cntrl_tb


add wave sim:/accel_spi_cntrl_tb/*

run 200 us