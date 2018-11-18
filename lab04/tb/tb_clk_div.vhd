----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:  10/07/2018 
-- Module Name:  tb_clk_div
-- Project Name:  Lab04
--
-- Description:  testbench for clock divider
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity tb_clk_div is
end entity tb_clk_div;

architecture tb of tb_clk_div is

signal clk,rst,clk_div : std_logic;

begin

  u_UUT : entity work.clk_div(rtl) 
    Port map(
      i_clk     => clk,
      i_reset   => rst,
      o_clk_div => clk_div);
      
  rst <= '0', '1' after 10 ns, '0' after 30 ns;

  p_clk_100MHz : process -- 100 MHz = 10 ns period
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;    

end architecture tb;


