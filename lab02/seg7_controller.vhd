----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  09/02/2018 
-- Module Name:  seg7_controller
-- Project Name:  Lab02
--
-- Description:  Driver that displays different digits on the 7 segment display
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

architecture Behavioral of seg7_controller is

  

begin




end architecture Behavioral;