----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/23/2018 
-- Module Name:   vga_controller
-- Project Name:  Lab03
--
-- Description:  vga controller for lab 03
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work. all;

entity vga_controller is
  Port(
    i_clk     : in     std_logic;
    i_rst     : in     std_logic;
    o_vga_red :   out  std_logic_vector(3 downto 0);
    o_vga_grn :   out  std_logic_vector(3 downto 0);
    o_vga_blu :   out  std_logic_vector(3 downto 0);
    o_h_sync  :   out  std_logic;
    o_v_sync  :   out  std_logic);
end entity vga_controller;

architecture rtl of vga_controller is

constant k_h_max       : unsigned(9 downto 0) := "11" & x"1F"; -- d799 = 0x31F
constant k_h_sync_low  : unsigned(9 downto 0) := "10" & x"90"; -- d656 = 0x290
constant k_h_sync_high : unsigned(9 downto 0) := "10" & x"F0"; -- d752 = 0x2F0
constant k_h_red       : unsigned(9 downto 0) := "10" & x"80"; -- d640 = 0x280
constant k_zero        : unsigned(9 downto 0) := "00" & x"00";

constant k_v_max       : unsigned(9 downto 0) := "10" & x"08"; -- d520 = 0x208
constant k_v_sync_low  : unsigned(9 downto 0) := "01" & x"EA"; -- d490 = 0x1EA
constant k_v_sync_high : unsigned(9 downto 0) := "01" & x"EC"; -- d492 = 0x1EC
constant k_v_red       : unsigned(9 downto 0) := "01" & x"E0"; -- d480 = 0x1E0


signal w_vga_red, w_vga_grn, w_vga_blu : std_logic;
signal w_en25, w_hsync, w_vsync : std_logic;
signal w_h_rst, w_v_rst : std_logic;
signal q_h_cnt, q_v_cnt, d_h_cnt, d_v_cnt : unsigned(9 downto 0);


begin
-- assign outputs
o_vga_red  <= "111" & w_vga_red;
o_vga_grn  <= "000" & w_vga_grn;
o_vga_blu  <= "000" & w_vga_blu;
o_h_sync   <= w_hsync;
o_v_sync   <= w_vsync;

-- generate counter resets with mux
w_h_rst <= '1' when q_h_cnt = k_h_max else '0';
w_v_rst <= '1' when q_v_cnt = k_v_max else '0';

-- increment counters
d_h_cnt <= q_h_cnt + 1;
d_v_cnt <= q_v_cnt + 1;

-- generate sync signals
w_hsync <= '1' when q_h_cnt >= k_h_sync_low AND q_h_cnt < k_h_sync_high else '0';
w_vsync <= '1' when q_v_cnt >= k_v_sync_low AND q_v_cnt < k_v_sync_high else '0';

-- assign colors
w_vga_grn <= '0';
w_vga_blu <= '0';

p_color : process(q_h_cnt, q_v_cnt)
  begin
    if (q_h_cnt >= k_zero AND q_h_cnt < k_h_red) then
      w_vga_red <= '1';
    else
      w_vga_red <= '0';
    end if;
end process p_color;

-- generate horizontal and vertical counters
p_cntrs : process(i_clk,i_rst)
  begin
    if (i_rst = '1') then 
      q_h_cnt <= (others => '0');
      q_v_cnt <= (others => '0');
    elsif (rising_edge(i_clk)) then
      if (w_en25 = '1') then
      
        if (w_h_rst = '1') then
          q_h_cnt <= (others => '0');
          q_v_cnt <= d_v_cnt;           -- increment vcount when hcount is reset
        else
          q_h_cnt <= d_h_cnt;    
        end if;
      
        if (w_v_rst = '1') then
          q_v_cnt <= (others => '0');
        end if;
      end if;
    end if;
  end process p_cntrs;
    

pulse25MHz : entity work.pgen_25MHz(rtl)
   Port map(
    i_clk   => i_clk,
    i_rst   => i_rst,
    o_pulse => w_en25);



end architecture rtl;

