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
-- screen:  15 rows by 20 columns, 480 x 640 = 32 by 32 pixles for each square
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
    i_clk      : in     std_logic;
    i_rst      : in     std_logic;
    i_db_up    : in     std_logic;
    i_db_left  : in     std_logic;
    i_db_right : in     std_logic;
    i_db_down  : in     std_logic;
    o_vga_red  :   out  std_logic_vector(3 downto 0);
    o_vga_grn  :   out  std_logic_vector(3 downto 0);
    o_vga_blu  :   out  std_logic_vector(3 downto 0);
    o_h_sync   :   out  std_logic;
    o_v_sync   :   out  std_logic;
    o_y_index  :   out  std_logic_vector(7 downto 0);
    o_x_index  :   out  std_logic_vector(7 downto 0));
end entity vga_controller;

architecture rtl of vga_controller is


-- red square constants 
constant k_h_rst : unsigned(9 downto 0) := to_unsigned(31,10);
constant k_v_rst : unsigned(9 downto 0) := to_unsigned(31,10);


-- horizontal counter constants
constant k_h_max       : unsigned(9 downto 0) := to_unsigned(799, 10);    
constant k_h_sync_low  : unsigned(9 downto 0) := to_unsigned(656, 10);
constant k_h_sync_high : unsigned(9 downto 0) := to_unsigned(752, 10);

-- vertical counter constants 
constant k_v_max       : unsigned(9 downto 0) := to_unsigned(520, 10);
constant k_v_sync_low  : unsigned(9 downto 0) := to_unsigned(490, 10);
constant k_v_sync_high : unsigned(9 downto 0) := to_unsigned(492, 10);


-- signal declarations
signal w_vga_red, w_vga_grn, w_vga_blu : std_logic;
signal w_en25, w_hsync, w_vsync : std_logic;
signal w_h_rst, w_v_rst, w_cmp : std_logic;
signal q_h_cnt, q_v_cnt, d_h_cnt, d_v_cnt : unsigned(9 downto 0);

signal w_h_red_low, w_v_red_low  : unsigned(9 downto 0);

signal w_h_cmp, w_v_cmp, w_square : std_logic;

begin
  
-- assign outputs
o_vga_red  <= w_vga_red & w_vga_red & w_vga_red & w_vga_red;
o_vga_grn  <= w_vga_grn & w_vga_grn & w_vga_grn & w_vga_grn;
o_vga_blu  <= w_vga_blu & w_vga_blu & w_vga_blu & w_vga_blu;
o_h_sync   <= w_hsync;
o_v_sync   <= w_vsync;

-- move red square
C_square : process(i_clk, i_rst, i_db_up, i_db_left, i_db_right, i_db_down)
begin
  if (i_rst = '1') then
    w_h_red_low  <= (others => '0');
    w_v_red_low  <= (others => '0');
  
  elsif (rising_edge(i_clk)) then
    if (i_db_up   = '1') then
      if ((w_v_red_low - 32) >= 992) then
        w_v_red_low <= to_unsigned(448, 10);        -- reset to y max = index 15 = 480 - 32 = 448
      else
        w_v_red_low  <= w_v_red_low  - 32;
      end if;
    elsif (i_db_left = '1') then
      if ((w_h_red_low - 32) >= 992) then
        w_h_red_low <= to_unsigned(608, 10); --640 - 32 = 608
      else
        w_h_red_low  <= w_h_red_low  - 32;
      end if;
    elsif (i_db_right = '1') then
      if ((w_h_red_low + 32) >= 640) then
        w_h_red_low <= (others => '0');
      else
        w_h_red_low  <= w_h_red_low  + 32;
      end if;
    elsif (i_db_down = '1') then
      if ((w_v_red_low + 32) >= 480) then
        w_v_red_low <= (others => '0');
      else
        w_v_red_low  <= w_v_red_low  + 32;
      end if;
    end if;
  end if;
end process;

-- red square indices for 7 seg display
o_x_index <= std_logic_vector(resize(shift_right(w_h_red_low, 5),8));
o_y_index <= std_logic_vector(resize(shift_right(w_v_red_low, 5),8));

-- assign colors
w_h_cmp  <= '1' when (q_h_cnt >= w_h_red_low) AND (q_h_cnt < (w_h_red_low + 32)) else '0';
w_v_cmp  <= '1' when (q_v_cnt >= w_v_red_low) AND (q_v_cnt < (w_v_red_low + 32)) else '0';
w_square <= '1' when w_h_cmp = '1' AND w_v_cmp = '1' else '0';
w_cmp    <= q_h_cnt(5) XOR q_v_cnt(5);

C_color : process (w_cmp, w_square)
begin
    if (w_square = '1') then
      w_vga_red <= '1';
      w_vga_grn <= '0';
      w_vga_blu <= '0';
    
    elsif (w_cmp = '0') then
      w_vga_red <= '0';
      w_vga_grn <= '1';
      w_vga_blu <= '0';
    else
      w_vga_red <= '0';
      w_vga_grn <= '0';
      w_vga_blu <= '1';
    end if;
end process;
        
  

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

