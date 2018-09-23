----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/23/2018 
-- Module Name:   tb_vga_controller
-- Project Name:  Lab03
--
-- Description:  testbench for vga_controller entity
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_vga_controller entity
entity tb_vga_controller is
end entity tb_vga_controller;

architecture tb of tb_vga_controller is 
  signal clk   : STD_LOGIC;
  signal rst   : STD_LOGIC;

  
begin
  UUT: entity work.vga_controller(rtl) 
      Port map(
        i_clk     => clk,
        i_rst     => rst);
  
  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  
  -- generate 100 MHz clock (10 ns period)
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;   
  
end architecture tb;