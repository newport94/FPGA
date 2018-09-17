vlib work
vmap work ./work
vcom -work work ../rtl/pulse_generator.vhd
vcom -work work ../rtl/char_shift_reg.vhd
vcom -work work ../tb/tb_char_shift_reg.vhd
vsim tb_char_shift_reg
