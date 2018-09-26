----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/25/2018 
-- Module Name:   lab03_top
-- Project Name:  Lab03
--
-- Description:  top level entity  for lab 03
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work. all;

entity lab03_top is 
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(0 downto 0);    -- Switch 0 will reset
    BTNU      : in    STD_LOGIC;                       -- push buttons
    BTNL      : in    STD_LOGIC;
    BTNR      : in    STD_LOGIC;
    BTND      : in    STD_LOGIC;
    VGA_R     :   out STD_LOGIC_VECTOR(3 downto 0);    -- vga controller
    VGA_G     :   out STD_LOGIC_VECTOR(3 downto 0);
    VGA_B     :   out STD_LOGIC_VECTOR(3 downto 0);
    VGA_HS    :   out STD_LOGIC;
    VGA_VS    :   out STD_LOGIC;
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0));
end entity lab03_top;

architecture rtl of lab03_top is 

signal w_db_up, w_db_left, w_db_right, w_db_down : std_logic;

begin


UP_BUTTON : entity work.debounce(rtl) 
  Port map(
    i_clk => CLK100MHZ;   -- 100 MHz clk
    i_rst => SW;
    i_pb  => BTNU;
    o_db  => w_db_up);
    
LEFT_BUTTON : entity work.debounce(rtl) 
  Port map(
    i_clk => CLK100MHZ;   -- 100 MHz clk
    i_rst => SW;
    i_pb  => BTNL;
    o_db  => w_db_left);

RIGHT_BUTTON : entity work.debounce(rtl) 
  Port map(
    i_clk => CLK100MHZ;   -- 100 MHz clk
    i_rst => SW;
    i_pb  => BTNR;
    o_db  => w_db_right);

DOWN_BUTTON : entity work.debounce(rtl) 
  Port map(
    i_clk => CLK100MHZ;   -- 100 MHz clk
    i_rst => SW;
    i_pb  => BTND;
    o_db  => w_db_down);
    


end architecture rtl;