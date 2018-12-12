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
  signal mclk2_red_w : std_logic;
  signal data_vol_w : std_logic_vector(15 downto 0);
  
  -- registers
  signal mclk2_d, mclk2_q : std_logic;
  signal shift_q : std_logic_vector(15 downto 0);

begin

  -- assign outputs

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

     
  p_shift_out : process(clk_100_i, rst_i)
  begin
    if (rst_i = '1') then 
      shift_q <= (others => '0');
    elsif (rising_edge(clk_100_i)) then 
      mclk2_q <= mclk2_d;
      if (mclk2_red_w = '1') then 
        if (vld_i = '1') then
          shift_q <= data_i;
        else
          shift_q   <= shift_q(14 downto 0) & '0';
          aud_pwm_o <= shift_q(15);
        end if;
      end if;
    end if;      
  end process p_shift_out;


  
    ------------------------------------------------------------------------------
  -- AUDIO CLOCK 2 MHz
  -----------------------------------------------------------------------------
  
  -- rising edge detect
  mclk2_red_w <= mclk2_d AND NOT mclk2_q;
  
  aud_clk_2MHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 25,
    g_max_width => 5)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => mclk2_d);
    
end architecture rtl;