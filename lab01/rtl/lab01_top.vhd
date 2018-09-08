----------------------------------------------------------------------------------
-- Compo_ANy:    JHU EP
-- Engineer:   Ryo_AN Newport
-- 
-- Create Date: 09/05/2018 
-- Design Name:  lab01
-- Module Name:   lab01_top - Behavioral
-- Project Name:  Lab 01
--
-- Description:  Lab01 top level

----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---- Common Anode Seven Segment Display layout
--      A                          To illuminate:
--     --                            - Drive anode high (use 0 b/c driven w/ transistor
--  F |  | B                         - Drive cathode low (use 0)
--     --  G                       Anode:    AN7 - AN0
--  E |  | C                       Cathode:  CA[0.3] .. CG[0.3]  DP[0.3]
--     --  
--      D
-------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab01_top is Port(
  i_BTNC      : in     STD_LOGIC;                       -- Push Button Center
  i_BTND      : in     STD_LOGIC;                       -- Push Button Down
  i_BTNU      : in     STD_LOGIC;                       -- Push Button Up
  i_SW        : in     STD_LOGIC_VECTOR(15 downto 0);   -- Switches (all 16)
  o_LED       :    out STD_LOGIC_VECTOR(15 downto 0);   -- LEDs (all 16)
  o_SEG7_CATH :    out STD_LOGIC_VECTOR(7 downto 0);    -- cathodes
  o_AN        :    out STD_LOGIC_VECTOR(7 downto 0));   -- Anodes
end entity lab01_top;

architecture Behavioral of lab01_top is

  component seg7_hex
    Port ( Digit : in     STD_LOGIC_VECTOR (3 downto 0);
           Seg7  :    out STD_LOGIC_VECTOR (7 downto 0));
  end component;

  signal w_seg_in : STD_LOGIC_VECTOR(3 downto 0);

begin

  -- mux for 0x0 or i_SW[3:0]
  -- push buttons generate high when pressed, otherwise low
  with i_BTNC select
    w_seg_in <= i_SW(3 downto 0) when '0',
                x"0"             when others;  

  -- when Center PB  : Anodes all '0' (all driven high = on)
  -- when Up Button  : Only upper four digits showing SW[3:0] value
  -- when Down Button: Only bottom four digits showing "          " 
  -- when NO Buttons : SW[11:4] dictates which number is on   
  -- for AN[a]: '0' is ON, '1' is OFF
  o_AN <=
    x"00" when i_BTNC = '1' else
    x"0F" when i_BTNU = '1' else 
    x"F0" when i_BTND = '1' else
    not i_SW(11 downto 4);

  -- Component Instatiation for Seven Segment Display entity 
  U1: seg7_hex Port map(Digit => w_seg_in,
                        Seg7  => o_SEG7_CATH);  

  -- Green LEDs light up based off of switches
  o_LED <= i_SW;

                          
                          
end architecture Behavioral;
  