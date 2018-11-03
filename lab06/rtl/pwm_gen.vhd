----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/29/2018 
-- Module Name:   pwm
-- Project Name:  Lab06
--
-- Description:  pulse width modulation entity for mono-audio output signal
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity pwm_gen is 
  Generic( 
    pwm_resolution : integer := 10);
  Port(
    clk_i        : in    STD_LOGIC;
    rst_i        : in    STD_LOGIC;
    duty_cycle_i : in    STD_LOGIC_VECTOR((pwm_resolution - 1) downto 0);
    pwm_o        :   out STD_LOGIC    
  );
end entity pwm_gen;

architecture rtl of pwm_gen is 

  constant MAX_CNT_K : unsigned((pwm_resolution - 1) downto 0) := to_unsigned(1023, 10);
  signal cntr_q : unsigned((pwm_resolution - 1) downto 0);
  signal synch_rst_w : std_logic;


begin

  pwm_o <= '0' when ((cntr_q >= unsigned(duty_cycle_i)) OR (synch_rst_w = '1')) else '1';
  synch_rst_w <= '1' when (cntr_q = MAX_CNT_K) else '0';

  S_PWM_CNTR : process(clk_i, rst_i)
  begin
    if (rst_i = '1' ) then 
      cntr_q <= (others => '0');
    elsif (rising_edge(clk_i)) then
      if (synch_rst_w = '1') then 
        cntr_q <= (others => '0');
      else
        cntr_q <= cntr_q + 1;
      end if;
    end if;
  end process S_PWM_CNTR;




end architecture rtl;

