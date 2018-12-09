----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/22/2018 
-- Module Name:   tb_clk_div_frac
-- Project Name:  Lab03
--
-- Description:  testbench for fractional clock divier module from the interwebs
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_clk_div_frac entity
entity tb_clk_div_frac is
end entity tb_clk_div_frac;

architecture tb of tb_clk_div_frac is 
  signal clk   : STD_LOGIC;
  signal rst   : STD_LOGIC;
  signal clk_div : STD_LOGIC;
  
begin
  UUT: entity work.clock_div_frac(rtl) 
      Port map(
        reset    => rst,
        clock    => clk,
        output   => clk_div);
  
  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;        -- 100 MHz clock (10 ns period)       
  
end architecture tb;