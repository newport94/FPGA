vlib work
vmap work ./work
vcom -work work ../rtl/sipo.vhd
vcom -work work ../rtl/piso.vhd
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../rtl/accel_spi_rw.vhd
vcom -work work ../tb/acl_model.vhd
vcom -work work ../tb/accel_spi_rw_tb.vhd
vsim accel_spi_rw_tb


add wave -noupdate -divider testbench
add wave -noupdate /accel_spi_rw_tb/clk
add wave -noupdate /accel_spi_rw_tb/reset
add wave -noupdate /accel_spi_rw_tb/ACL_CSN
add wave -noupdate /accel_spi_rw_tb/ACL_MOSI
add wave -noupdate /accel_spi_rw_tb/ACL_SCLK
add wave -noupdate /accel_spi_rw_tb/ACL_MISO
add wave -noupdate /accel_spi_rw_tb/acl_enabled
add wave -noupdate /accel_spi_rw_tb/ID_AD
add wave -noupdate /accel_spi_rw_tb/ID_1D
add wave -noupdate /accel_spi_rw_tb/DATA_X
add wave -noupdate /accel_spi_rw_tb/DATA_Y
add wave -noupdate /accel_spi_rw_tb/DATA_Z
add wave -noupdate -divider spi_controller



