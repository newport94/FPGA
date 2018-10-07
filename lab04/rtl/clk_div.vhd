----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  10/07/2018 
-- Module Name:  clk_div
-- Project Name:  Lab04
--
-- Description:  clock divider for a 100 MHz clock with generic max count input
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity clk_div is 
  Generic(
    g_max_cnt   : integer := 1000000);  -- default to 100 MHZ/100 = 1 MHz
  Port(
    i_clk       : in     STD_LOGIC;   -- 100 MHz clock
    i_reset     : in     STD_LOGIC;   -- asynchronous reset
    o_clk_div   :    out STD_LOGIC);  -- Clock div out
end clk_div;

architecture rtl of clk_div is 
  signal w_clk_temp      : std_logic;
  signal cntr, w_max_cnt : unsigned (26 downto 0);  

begin

  w_max_cnt <= to_unsigned(g_max_cnt, cntr'length);


  p_clk_div:  process(i_clk, i_reset)
  begin
    if (i_reset = '1') then 
      cntr       <= (others => '0');
      w_clk_temp <= '0';
    elsif (rising_edge(i_clk)) then 
      if (cntr = w_max_cnt) then 
        cntr       <= (others => '0');
        w_clk_temp <= not w_clk_temp;
      else
        cntr <= cntr + 1;
      end if; 
    end if;      
  end process p_clk_div;
  
  o_clk_div <= w_clk_temp;

end architecture rtl;