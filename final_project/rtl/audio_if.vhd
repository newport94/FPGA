----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   12/9/2018 
-- Module Name:   audio_if
-- Project Name:  Final Project
--
-- Description: interface for audio output.  Controls volume and generates pwm signal
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity audio_if is
  Port(
    clk_100_i   : in    STD_LOGIC;
    rst_i       : in    STD_LOGIC;  
    data_i      : in    STD_LOGIC_VECTOR(15 downto 0);
    vld_i       : in    STD_LOGIC;
    sw_vol_i    : in    STD_LOGIC_VECTOR(2 downto 0);
    aud_pwm_o   :   out STD_LOGIC);
end entity audio_if;

architecture rtl of audio_if is

  -- wires
  signal pwm_w : std_logic;
  signal data_vol_w : std_logic_vector(15 downto 0);

begin


  -- assign outputs

  aud_pwm_o <= pwm_w;



  with sw_vol_i select
   data_vol_w <=
     std_logic_vector(shift_right(unsigned(data_i), 7)) when "000",
     std_logic_vector(shift_right(unsigned(data_i), 6)) when "001",
     std_logic_vector(shift_right(unsigned(data_i), 5)) when "010",
     std_logic_vector(shift_right(unsigned(data_i), 4)) when "011",
     std_logic_vector(shift_right(unsigned(data_i), 3)) when "100",
     std_logic_vector(shift_right(unsigned(data_i), 2)) when "101",
     std_logic_vector(shift_right(unsigned(data_i), 1)) when "110",
     data_i                 when others;

  U_PWM_GEN: entity work.pwm_gen(rtl)
    Generic map( 
      pwm_res => 16)
    Port map(
      clk_i        => clk_100_i,
      rst_i        => rst_i,
      duty_cycle_i => data_vol_w,
      pwm_o        => pwm_w);   

end architecture rtl;