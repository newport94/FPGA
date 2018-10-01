----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/12/2018 
-- Module Name:    seg7_controller
-- Project Name:   Lab02
-- Target Device:  Xilinx Artix-7 XC7A100T-1CSG324C
--
-- Description:  Driver that displays different digits on the 7 segment display.
--               Uses time multiplexing to display different chars on each

-- Seven seg display chars are numbered as follows
--      7     6     5      4        3     2     1     0
--  --------------------------- --------------------------
--  |   --    --    --    --  | |  --    --    --    --  |
--  |  |  |  |  |  |  |  |  | | | |  |  |  |  |  |  |  | |
--  |   --    --    --    --  | |  --    --    --    --  |
--  |  |  |  |  |  |  |  |  | | | |  |  |  |  |  |  |  | |
--  |   --    --    --    --  | |  --    --    --    --  |
--  --------------------------- --------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;


entity seg7_controller is
  Port ( i_clk   : in     STD_LOGIC;                     -- 100 MHz clock
         i_rst   : in     STD_LOGIC;                     -- asynchronous reset
         i_char0 : in     STD_LOGIC_VECTOR(3 downto 0);  -- the 8 hex characters to display
         i_char1 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char2 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char3 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char4 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char5 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char6 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char7 : in     STD_LOGIC_VECTOR(3 downto 0);
         o_AN    :    out STD_LOGIC_VECTOR(7 downto 0);
         o_EN    :    out STD_LOGIC_VECTOR(7 downto 0));  -- encoded character                 
end seg7_controller;

architecture rtl of seg7_controller is

  constant c_max_cnt : unsigned(16 downto 0) := '1' & x"86A0";  -- hex for 100,000
  signal   w_pulse   : STD_LOGIC;
  signal   w_char    : STD_LOGIC_VECTOR(3 downto 0);
  signal   w_an_sel  : STD_LOGIC_VECTOR(2 downto 0);
  
begin
  PGEN_1KHZ: entity work.pgen_1kHz(rtl)
    Port map(
      i_clk     => i_clk,
      i_reset   => i_rst,
      i_max_cnt => c_max_cnt,
      o_pulse   => w_pulse);
  
  -- calculate current anode
  AN_SEL: entity work.anode_sel(rtl)
    Port map(
      i_clk    => i_clk,
      i_rst    => i_rst,
      i_pulse  => w_pulse,
      o_an_sel => w_an_sel);
      
  -- 7 segment enocder (from lab01)
  SEG7_EN:  entity work.seg7_hex(rtl)
    Port map( 
      Digit => w_char, 
      Seg7  => o_EN);  
      
  
  -- character selection mux
  with w_an_sel select
    w_char <= 
      i_char7 when "111",
      i_char6 when "110",
      i_char5 when "101",
      i_char4 when "100",
      i_char3 when "011",
      i_char2 when "010",
      i_char1 when "001",
      i_char0 when others;
  
  -- set anodes
  with w_an_sel select
    o_AN <=
      "01111111" when "111", 
      "10111111" when "110",
      "11011111" when "101",
      "11101111" when "100",
      "11110111" when "011",
      "11111011" when "010",
      "11111101" when "001",
      "11111110" when others;     
      
 
end architecture rtl;