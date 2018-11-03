----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   11/1/2018 
-- Module Name:   lab06_top_tb
-- Project Name:  Lab06
--
-- Description:  testbench for lab06_top
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity lab06_top_tb is 
end entity lab06_top_tb;

architecture tb of lab06_top_tb is 

signal clk, rst, pwm, sd : std_logic;
signal switches : STD_LOGIC_VECTOR(15 downto 0);
constant T_CLK : time := 5 ns;

begin

  process
  begin
    clk <= '1';
    wait for T_CLK/2;
    clk <= '0';
    wait for T_CLK/2;
  end process;
    
  rst <= '0', '1' after 2*T_CLK, '0' after 4 * T_CLK;
    
  switches(15) <= '1';
  switches(14 downto 6) <= '0' & x"00";
  switches(5 downto 3) <= "111";
  switches(2 downto 0) <= "010";




  UUT : entity work.lab06_top(rtl)
    Port map(
      CLK100MHZ => clk,
      SW        => switches,
      BTNC      => rst,
      SEG7_CATH => open,
      AN        => open,
      AUD_PWM   => pwm,
      AUD_SD    => sd);




end architecture tb;