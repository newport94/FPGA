----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  09/02/2018 
-- Module Name:  pulse_gen_1Hz
-- Project Name:  Lab02
--
-- Description:  Driver that displays different digits on the 7 segment display
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity pulse_gen_1Hz is Port(
  i_clk     : in     STD_LOGIC;   -- 100 MHz clock
  i_reset   : in     STD_LOGIC;   -- asynchronous reset
  i_max_cnt : in     unsigned(26 downto 0);
  o_pulse   :    out STD_LOGIC);
end pulse_gen_1Hz;

architecture rtl of pulse_gen_1Hz is 
  signal cntr       : unsigned (26 downto 0);
  signal synchReset : STD_LOGIC;

begin
  p_pulse_gen:  process(i_clk, i_reset)
  begin
    if (i_reset = '1') then 
      cntr <= (others => '0');
    elsif (rising_edge(i_clk)) then 
      if (synchReset = '1') then 
        cntr <= (others => '0');
      else
        cntr <= cntr + 1;
      end if; 
    end if;      
  end process p_pulse_gen;
  
  synchReset <= '1' when cntr = i_max_cnt else '0';
  o_pulse    <= synchReset;

end architecture rtl;