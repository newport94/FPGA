----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  10/13/2018 
-- Module Name:  pulse_gen
-- Project Name:  Lab06
--
-- Description:  pulse generator entity with generics for any max count
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity pulse_gen is 
  Port(
    i_clk     : in    STD_LOGIC; -- 100 MHz clock
    i_rst     : in    STD_LOGIC; -- asynchronous reset
    i_max_val : in    STD_LOGIC_VECTOR(9 downto 0);
    o_pulse   :   out STD_LOGIC);
end entity pulse_gen;

architecture rtl of pulse_gen is

signal cntr : unsigned(9 downto 0);
signal synchReset : std_logic;

begin

  synchReset <= '1' when cntr = i_max_val else '0';
  o_pulse    <= synchReset;

  process(i_clk,i_rst)
  begin
    if (i_rst = '1') then
      cntr <= (others => '0');
    elsif (rising_edge(i_clk)) then
      if (synchReset = '1') then
        cntr <= (others => '0');
      else
        cntr <= cntr + 1;
      end if;
    end if;
  end process;

end architecture rtl;