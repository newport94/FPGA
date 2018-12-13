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
    data_vld_i  : in    STD_LOGIC;
    rd_req_o    :   out STD_LOGIC;
    sw_vol_i    : in    STD_LOGIC_VECTOR(2 downto 0);
    aud_pwm_o   :   out STD_LOGIC);
end entity audio_if;

architecture rtl of audio_if is

  -- wires
  signal mclk2_red_w, rd_clk_red_w : std_logic;
  
  -- registers
  signal mclk2_d, mclk2_q, rd_clk_d, rd_clk_q : std_logic;
  signal shift_q : std_logic_vector(15 downto 0);
 -- signal q_cntr : std_logic_vector(4 downto 0);

begin

  -- assign read_request
  rd_req_o <= rd_clk_red_w;

     
  p_shift_out : process(clk_100_i, rst_i)
  begin
    if (rst_i = '1') then 
      shift_q <= (others => '0');
      mclk2_q <= '0';
    elsif (rising_edge(clk_100_i)) then 
      mclk2_q  <= mclk2_d;
      rd_clk_q <= rd_clk_d;

      if (data_vld_i = '1') then
        shift_q <= data_i;      
      elsif (mclk2_red_w = '1') then 
        
        shift_q   <= shift_q(14 downto 0) & '0';
        aud_pwm_o <= shift_q(15);
      end if;
    end if;      
  end process p_shift_out;

      
  
    ------------------------------------------------------------------------------
  -- AUDIO CLOCK 2 MHz
  -----------------------------------------------------------------------------
  
  -- rising edge detect
  --mclk2_red_w <= mclk2_d AND NOT mclk2_q;
  mclk2_red_w  <= mclk2_d AND NOT mclk2_q;
  rd_clk_red_w <= rd_clk_d AND NOT rd_clk_q;

  aud_clk_2MHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 25,
    g_max_width => 5)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => mclk2_d);
    
  rd_clk_125kHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 400,
    g_max_width => 9)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => rd_clk_d);    
    
end architecture rtl;