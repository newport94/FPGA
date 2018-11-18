vlib work
vmap work ./work
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../rtl/accel_spi_rw2.vhd
vcom -work work ../tb/accel_spi_rw2_tb.vhd
vsim accel_spi_rw2_tb


add wave -noupdate /accel_spi_rw2_tb/U_UUT/*


run 6000 ns;