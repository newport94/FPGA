vlib work
vmap work ./work
vcom -work work ../rtl/vga_controller.vhd
vcom -work work ../rtl/pgen_25MHz.vhd
vcom -work work ../tb/tb_Vga_controller.vhd
vsim tb_vga_controller

add wave  \
sim:/tb_vga_controller/UUT/i_clk \
sim:/tb_vga_controller/UUT/i_rst \
sim:/tb_vga_controller/UUT/w_en25 \
sim:/tb_vga_controller/UUT/w_hsync \
sim:/tb_vga_controller/UUT/w_h_rst \
sim:/tb_vga_controller/UUT/d_h_cnt \
sim:/tb_vga_controller/UUT/q_h_cnt \
sim:/tb_vga_controller/UUT/w_vsync \
sim:/tb_vga_controller/UUT/d_v_cnt \
sim:/tb_vga_controller/UUT/w_v_rst \
sim:/tb_vga_controller/UUT/q_v_cnt \
sim:/tb_vga_controller/UUT/w_vga_red \
sim:/tb_vga_controller/UUT/w_vga_grn \
sim:/tb_vga_controller/UUT/w_vga_blu \

run 200 ns
