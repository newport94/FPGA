----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/15/2018 
-- Module Name:   tb_seg7_controller
-- Project Name:  Lab02
--
-- Description:  testbench for pulse generator entity
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_seg7_controller entity
entity tb_seg7_controller is
end entity tb_seg7_controller;

architecture tb of tb_seg7_controller is 
  signal clk       : STD_LOGIC;
  signal rst       : STD_LOGIC;
  signal AN        : STD_LOGIC_VECTOR(7 downto 0);
  signal SEG7_CATH : STD_LOGIC_VECTOR(7 downto 0);
  
begin
  UUT: entity work.seg7_controller(rtl)
    Port map( 
      i_clk   => clk        ,   -- STD_LOGIC;                     
      i_rst   => rst,        -- STD_LOGIC;                     
      i_char0 => x"1",          -- STD_LOGIC_VECTOR(3 downto 0)  
      i_char1 => x"3",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char2 => x"5",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char3 => x"7",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char4 => x"9",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char5 => x"B",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char6 => x"D",          -- STD_LOGIC_VECTOR(3 downto 0)
      i_char7 => x"F",          -- STD_LOGIC_VECTOR(3 downto 0)
      o_AN    => AN,            -- STD_LOGIC_VECTOR(7 downto 0)
      o_EN    => SEG7_CATH);    -- STD_LOGIC_VECTOR(7 downto 0)  
  
  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;        -- 100 MHz clock (10 ns period)       
  
end architecture tb;