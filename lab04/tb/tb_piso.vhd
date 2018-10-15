----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/14/2018 
-- Module Name:   tb_piso
-- Project Name:  Lab04
--
-- Description:  parallel in serial out testbench
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity tb_piso is
end entity tb_piso;

architecture tb of tb_piso is

signal clk, rst, dout: std_logic;
signal mode : std_logic_vector(1 downto 0);
signal din : std_logic_vector(23 downto 0);

begin

  -- 100 MHz clock
  process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;
  
  rst <= '0', '1' after 10 ns, '0' after 30 ns;
  
  din <= x"AA" & x"55" & x"11";
  
  mode <= "00", "01" after 40 ns, "10" after 50 ns;
  
  
  
  U_UUT : entity work.piso(rtl)
    Port map(
      i_clk   =>  clk,
      i_rst   =>  rst,
      i_din   =>  din,
      i_mode  =>  mode,
      o_sdout =>  dout);    



end architecture tb;