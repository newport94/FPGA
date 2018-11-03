----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/31/2018 
-- Module Name:   pwm_gen_tb
-- Project Name:  Lab06
--
-- Description:  testbench for pwm_gen
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity pwm_gen_tb is 
end entity pwm_gen_tb;

architecture tb of pwm_gen_tb is 

  component pwm_gen
    Generic( 
      pwm_resolution : integer);
    Port(
      clk_i        : in    STD_LOGIC;
      rst_i        : in    STD_LOGIC;
      duty_cycle_i : in    STD_LOGIC_VECTOR((pwm_resolution - 1) downto 0);
      pwm_o        :   out STD_LOGIC    
    );
  end component;  
  
  signal clk, rst, pwm_out : std_logic;
  signal duty_cycle : std_logic_vector(9 downto 0);
  
  constant T_CLK : time := 5 ns;
  
  type test_vec is array (0 to 3) of unsigned(9 downto 0);
  signal test_case : test_vec := (to_unsigned(0,10), to_unsigned(256,10), 
                                  to_unsigned(512,10), to_unsigned(1023, 10));
    
begin

  process
  begin
    clk <= '1';
    wait for T_CLK/2;
    clk <= '0';
    wait for T_CLK/2;
  end process;
    
    
  rst <= '0' ,'1' after 2*T_CLK, '0' after 4*T_CLK;
    
  process
  begin
    wait for 5 * T_CLK;
    duty_cycle <= std_logic_vector(test_case(3));

    wait;
  end process;
  
  



  UUT: pwm_gen
    Generic map( 
      pwm_resolution => 10)
    Port map(
      clk_i        => clk,
      rst_i        => rst,
      duty_cycle_i => duty_cycle,
      pwm_o        => pwm_out);   



end architecture tb;