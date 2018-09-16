----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/16/2018 
-- Module Name:    lab02_top
-- Project Name:   Lab02
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  Top level entity for lab 02.  Implements a time multiplexed 
--               seven segment display for all 8 digits.  Moves in time at rate 
--               of 1 Hz from right to left
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity lab02_top is 
  Port(
    i_CLK100MHZ : in    STD_LOGIC;
    i_BTNC      : in    STD_LOGIC;
    i_SW        : in    STD_LOGIC_VECTOR(3 downto 0);
--  o_LED       :   out STD_LOGIC_VECTOR(15 downto 0);
    o_SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);
    o_AN        :   out STD_LOGIC_VECTOR(7 downto 0));
end entity lab02_top;

architecture rtl of lab02_top is

begin 

  SEG7_CNTRL: entity work.seg7_controller(rtl)
    Port map( 
      i_clk   => i_CLK100MHZ,   -- STD_LOGIC;                     
      i_rst   => i_BTNC,        -- STD_LOGIC;                     
      i_char0 => x"1",          -- STD_LOGIC_VECTOR(3 downto 0)  
      i_char1 => x"3",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char2 => x"5",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char3 => x"7",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char4 => x"9",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char5 => x"B",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char6 => x"D",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char7 => x"F",          -- STD_LOGIC_VECTOR(3 downto 0)
      o_AN    => o_AN,          -- STD_LOGIC_VECTOR(7 downto 0)
      o_EN    => o_SEG7_CATH);   -- STD_LOGIC_VECTOR(7 downto 0)               

end architecture rtl;