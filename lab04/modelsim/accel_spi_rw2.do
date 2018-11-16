vlib work
vmap work ./work
vcom -work work ../rtl/clk_div.vhd
vcom -work work ../rtl/accel_spi_rw2.vhd
vcom -work work ../tb/accel_spi_rw2_tb.vhd
vsim accel_spi_rw2_tb


add wave -noupdate /accel_spi_rw2_tb/U_UUT/i_MISO
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_MISO
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_dout
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_MOSI
add wave -noupdate /accel_spi_rw2_tb/U_UUT/o_dout
add wave -noupdate /accel_spi_rw2_tb/U_UUT/i_clk
add wave -noupdate /accel_spi_rw2_tb/U_UUT/i_mode
add wave -noupdate /accel_spi_rw2_tb/U_UUT/i_rst
add wave -noupdate /accel_spi_rw2_tb/U_UUT/i_din
add wave -noupdate /accel_spi_rw2_tb/U_UUT/o_done
add wave -noupdate /accel_spi_rw2_tb/U_UUT/o_MOSI
add wave -noupdate /accel_spi_rw2_tb/U_UUT/o_CS
add wave -noupdate /accel_spi_rw2_tb/U_UUT/o_SCLK
add wave -noupdate /accel_spi_rw2_tb/U_UUT/curr_state
add wave -noupdate /accel_spi_rw2_tb/U_UUT/next_state
add wave -noupdate /accel_spi_rw2_tb/U_UUT/w_start_shift
add wave -noupdate /accel_spi_rw2_tb/U_UUT/w_shift_done
add wave -noupdate /accel_spi_rw2_tb/U_UUT/w_sclk_red
add wave -noupdate /accel_spi_rw2_tb/U_UUT/w_sclk_fed
add wave -noupdate /accel_spi_rw2_tb/U_UUT/w_cntr_en
add wave -noupdate /accel_spi_rw2_tb/U_UUT/d_SCLK
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_SCLK
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_bit_cntr
add wave -noupdate /accel_spi_rw2_tb/U_UUT/q_MOSI_shift

run 6000 ns;