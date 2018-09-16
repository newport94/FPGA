vlib work
vmap work ./work
vcom -work work ../rtl/anode_sel.vhd
vcom -work work ../rtl/seg7_hex.vhd
vcom -work work ../rtl/pulse_generator.vhd
vcom -work work ../rtl/seg7_controller.vhd
vcom -work work ../tb/tb_seg7_controller.vhd
vsim tb_seg7_controller
