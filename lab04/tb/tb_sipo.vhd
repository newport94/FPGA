----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/14/2018 
-- Module Name:   tb_sipo
-- Project Name:  Lab04
--
-- Description:  serial in parallel out testbench
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity tb_sipo is
end entity tb_sipo;

architecture tb of tb_sipo is

signal clk, rst, sin, en, vld  : std_logic;
signal dout : std_logic_vector(7 downto 0);

begin

  -- 100 MHz clock
  process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;
  
  rst <= '0', '1' after 10 ns, '0' after 30 ns;
  
  sin <= '0', '1' after 50 ns, '0' after 60 ns, '1' after 70 ns, '0' after 80 ns, '0' after 90 ns,
          '1' after 100 ns, '0' after 110 ns, '1' after 120 ns;
  
  en <= '0', '1' after 50 ns, '0' after 150 ns;
  
  
  
  U_UUT : entity work.sipo(rtl)
    Port map(
        i_clk  => clk   ,
        i_rst  => rst   ,
        i_sin  => sin   ,
        i_en   => en    ,
        o_pout => dout  ,
        o_vld  => vld);

end architecture tb;