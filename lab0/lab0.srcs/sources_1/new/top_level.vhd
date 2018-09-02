----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date: 09/01/2018 03:33:28 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name:    Lab 0
--
-- Description:  Tutorial Top Level which displays the SW(3:0) input as a hexadecimal
--               digit on one of the 7-segment displays
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top_level is
  Port ( SW        : in     STD_LOGIC_VECTOR (3 downto 0);
         SEG7_CATH :    out STD_LOGIC_VECTOR (7 downto 0);
         AN        :    out STD_LOGIC_VECTOR (7 downto 0));
end top_level;

architecture Behavioral of top_level is

  signal display_digit : STD_LOGIC_VECTOR(3 downto 0);

begin
-----------------------------------------------------------------------------------
---- Common Anode Seven Segment Display layout
--      A                          To illuminate:
--     --                            - Drive anode high (use 0 b/c driven w/ transistor
--  F |  | B                         - Drive cathode low (use 0)
--     --  G                       Anode:    AN7 - AN0
--  E |  | C                       Cathode:  CA[0.3] .. CG[0.3]  DP[0.3[
--     --  
--      D
-------------------------------------------------------------------------------------
  display_digit <= SW(3 downto 0);

  -- Selected Signal Assignment
    -- no priority inferred  (as compared to conditional:  when, else)
    -- Need to end with "others"
  with display_digit select
    SEG7_CATH <=
-- C: "dGFEDCAB"               d = decimal point
      "11000000" when x"0",
      "11111001" when x"1",
      "10100100" when x"2",
      "10110000" when x"3",
      "10011001" when x"4",
      "10010010" when x"5",
      "10000010" when x"6",
      "11111000" when x"7",
      "10000000" when x"8",
      "10010000" when x"9",
      "10001000" when x"A",
      "10000011" when x"B",
      "11000110" when x"C",
      "10100001" when x"D",
      "10000110" when x"E",
      "10001110" when others;
  AN <= (0 => '0', others => '1');  --only AN7 is driven high, rest low and won't display on that segment
  
end Behavioral;
