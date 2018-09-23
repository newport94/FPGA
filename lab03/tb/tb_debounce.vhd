----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/18/2018 
-- Module Name:    tb_debounce
-- Project Name:   Lab03
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  testbench for debounce module
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity tb_debounce is
end entity tb_debounce;

architecture tb of tb_debounce is

signal clk,rst,pb,db : std_logic;


begin

  rst <= '0','1' after 20 ns, '0' after 60 ns;
  pb <= '0', '1' after 100 ns, '0' after 600 ns, '1' after 800 ns, '0' after 2000 ns;

  process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  UUT : entity work.debounce(rtl)
  Port map(
    i_clk => clk,
    i_rst => rst,
    i_pb  => pb,
    o_db  => db);


end architecture tb;