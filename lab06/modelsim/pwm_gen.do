vlib work
vmap work ./work
vcom -work work ../rtl/pwm_gen.vhd
vcom -work work ../tb/pwm_gen_tb.vhd
vsim pwm_gen_tb


add wave  \
sim:/pwm_gen_tb/UUT/clk_i \
sim:/pwm_gen_tb/UUT/rst_i \
sim:/pwm_gen_tb/UUT/duty_cycle_i \
sim:/pwm_gen_tb/UUT/pwm_o \
sim:/pwm_gen_tb/UUT/cntr_q \
sim:/pwm_gen_tb/UUT/synch_rst_w \
sim:/pwm_gen_tb/UUT/MAX_CNT_K \

run 3000 ns