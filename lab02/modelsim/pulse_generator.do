vlib work
vmap work ./work
vcom -work work ../rtl/pulse_generator.vhd
vcom -work work ../tb/tb_pulse_generator.vhd
vsim tb_pulse_generator

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_pulse_generator/clk
add wave -noupdate /tb_pulse_generator/rst
add wave -noupdate /tb_pulse_generator/max_cnt
add wave -noupdate /tb_pulse_generator/pulse_1kHz
add wave -noupdate /tb_pulse_generator/UUT/i_clk
add wave -noupdate /tb_pulse_generator/UUT/i_reset
add wave -noupdate /tb_pulse_generator/UUT/i_max_cnt
add wave -noupdate /tb_pulse_generator/UUT/o_pulse
add wave -noupdate /tb_pulse_generator/UUT/cntr
add wave -noupdate /tb_pulse_generator/UUT/synchReset
TreeUpdate [SetDefaultTree]
config wave -signalnamewidth 1
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}

run 200 ns
