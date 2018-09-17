library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity tb_one_pps is 
end entity tb_one_pps;

architecture tb of tb_one_pps is
  
  signal rst, clk, pps: std_logic;
  
begin
  
  p_clk: process
  begin
    clk <= '1';
    wait for 1 ps;
    clk <= '0';
    wait for 1 ps;
  end process;
  
  rst <= '0', '1' after 6 ps, '0' after 12 ps;
  
  UUT: entity work.one_pps(rtl)
  Port map(
    clk => clk,
    rst => rst,
    pps => pps
  ); 
  
end architecture tb;