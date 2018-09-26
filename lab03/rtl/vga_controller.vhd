----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/23/2018 
-- Module Name:   vga_controller
-- Project Name:  Lab03
--
-- Description:  vga controller for lab 03
--
--
-- 0   = 0x00 = 0000_0000
-- 31  = 0x1F = 0001_1111   E 0X_XXXX
--
-- 32  = 0x20 = 0010_0000   O 1X_XXXX
-- 63  = 0x3F = 0011_1111
--
-- 64  = 0x40 = 0100_0000   E 0X_XXXX
-- 95  = 0x5F = 0101_1111
--
-- 96  = 0x60 = 0110_0000   O 1X_XXXX
-- 127 = 0x7F = 0111_1111

-- 128 = 0x80 = 1000_0000   E
-- 159 = 0x9F = 1001_1111

-- 160 = 0xA0 = 1010_0000  O
-- 191 = 0xBF = 1011_1111
--
-- 192 = 0xC0 = 1100_0000  E
-- 223 = 0xDF = 1101_1111
--
-- 224 = 0xE0 = 1110_0000  O
-- 255 = 0xFF = 1111_1111
--
-- 256 = 0x100 = 0001_0000_0000
-- 287 = 0x11F = 0001_0001_1111
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

constant k_h_max       : unsigned(9 downto 0) := to_unsigned(799, 10); --"11" & x"1F"; -- d799 = 0x31F          
constant k_h_sync_low  : unsigned(9 downto 0) := to_unsigned(656, 10); --"10" & x"90"; -- d656 = 0x290
constant k_h_sync_high : unsigned(9 downto 0) := to_unsigned(752, 10); --"10" & x"F0"; -- d752 = 0x2F0
--constant k_h_red       : unsigned(9 downto 0) := "10" & x"80"; -- d640 = 0x280
--constant k_zero        : unsigned(9 downto 0) := "00" & x"00";

constant k_v_max       : unsigned(9 downto 0) := to_unsigned(520, 10); --"10" & x"08"; -- d520 = 0x208
constant k_v_sync_low  : unsigned(9 downto 0) := to_unsigned(490, 10); --"01" & x"EA"; -- d490 = 0x1EA
constant k_v_sync_high : unsigned(9 downto 0) := to_unsigned(492, 10); --"01" & x"EC"; -- d492 = 0x1EC
--constant k_v_red       : unsigned(9 downto 0) := "01" & x"E0"; -- d480 = 0x1E0


signal w_vga_red, w_vga_grn, w_vga_blu : std_logic;
signal w_en25, w_hsync, w_vsync : std_logic;
signal w_h_rst, w_v_rst, w_cmp : std_logic;
signal q_h_cnt, q_v_cnt, d_h_cnt, d_v_cnt : unsigned(9 downto 0);


begin
  
-- assign outputs
o_vga_red  <= w_vga_red & w_vga_red & w_vga_red & w_vga_red;
o_vga_grn  <= w_vga_grn & w_vga_grn & w_vga_grn & w_vga_grn;
o_vga_blu  <= w_vga_blu & w_vga_blu & w_vga_blu & w_vga_blu;
o_h_sync   <= w_hsync;
o_v_sync   <= w_vsync;


w_vga_red <= '0';
w_cmp <= q_h_cnt(5) XOR q_v_cnt(5);

p_color : process (w_cmp)
begin
    if (w_cmp = '0') then
      w_vga_grn <= '1';
      w_vga_blu <= '0';
    else
      w_vga_grn <= '0';
      w_vga_blu <= '1';
    end if;
end process;
        
  
---- assign colors
--w_vga_grn <= '0';
--w_vga_blu <= '0';
--
--p_color : process(q_h_cnt, q_v_cnt)
--  begin
--    if (q_h_cnt >= k_zero AND q_h_cnt < k_h_red) then
--      w_vga_red <= '1';
--    else
--      w_vga_red <= '0';
--    end if;
--end process p_color;



-- generate counter resets with mux
w_h_rst <= '1' when q_h_cnt = k_h_max else '0';
w_v_rst <= '1' when q_v_cnt = k_v_max else '0';


-- generate sync signals
w_hsync <= '0' when q_h_cnt >= k_h_sync_low AND q_h_cnt < k_h_sync_high else '1';
w_vsync <= '0' when q_v_cnt >= k_v_sync_low AND q_v_cnt < k_v_sync_high else '1';
  
  
-- Sequential to generate horizontal and vertical counters
S_cntrs : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_h_cnt <= (others => '0');
      q_v_cnt <= (others => '0');
    elsif (rising_edge(i_clk)) then
      if (w_en25 = '1') then
      
        if (w_h_rst = '1') then
          q_h_cnt <= (others => '0');
          q_v_cnt <= q_v_cnt + 1;           -- increment vcount when hcount is reset
        else
          q_h_cnt <= q_h_cnt + 1;    
        end if;
      
        if (w_v_rst = '1') then
          q_v_cnt <= (others => '0');
        end if;
      end if;
    end if;
  end process S_cntrs;
    

pulse25MHz : entity work.pgen_25MHz(rtl)
   Port map(
    i_clk   => i_clk,
    i_rst   => i_rst,
    o_pulse => w_en25);



end architecture rtl;

