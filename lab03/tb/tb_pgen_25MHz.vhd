----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/22/2018 
-- Module Name:   tb_pgen_25MHz
-- Project Name:  Lab03
--
-- Description:  testbench for pulse generator entity
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_pgen_25MHz entity
entity tb_pgen_25MHz is
end entity tb_pgen_25MHz;

architecture tb of tb_pgen_25MHz is 
  signal clk        : STD_LOGIC;
  signal rst        : STD_LOGIC;
  signal pulse : STD_LOGIC;
  
begin
  UUT: entity work.pgen_25MHz(rtl) 
      Port map(
        i_clk     => clk,
        i_rst   => rst,
        o_pulse   => pulse);
  
  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;        -- 100 MHz clock (10 ns period)       
  
end architecture tb;