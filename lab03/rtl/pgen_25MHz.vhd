----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  09/22/2018 
-- Module Name:  pgen_25MHz
-- Project Name:  Lab03
--
-- Description:  
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity pgen_25MHz is 
  Port(
    i_clk     : in    STD_LOGIC; -- 100 MHz clock
    i_rst     : in    STD_LOGIC; -- asynchronous reset
    o_pulse   :   out STD_LOGIC);
end entity pgen_25MHz;

architecture rtl of pgen_25MHz is

constant k_max_val : unsigned(1 downto 0) := "11";
signal cntr : unsigned(1 downto 0);
signal synchReset : std_logic;

begin

  synchReset <= '1' when cntr = k_max_val else '0';
  o_pulse   <= synchReset;

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