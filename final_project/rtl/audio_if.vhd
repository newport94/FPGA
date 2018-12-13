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
    clk_100_i    : in    STD_LOGIC;
    rst_i        : in    STD_LOGIC;  
    data_i       : in    STD_LOGIC_VECTOR(15 downto 0);
    data_vld_i   : in    STD_LOGIC;
    rd_req_o     :   out STD_LOGIC;
    sw_vol_i     : in    STD_LOGIC_VECTOR(2 downto 0);
    aud_pwm_o    :   out STD_LOGIC;
    play_speed_i : in    STD_LOGIC_VECTOR(1 DOWNTO 0));
end entity audio_if;

architecture rtl of audio_if is

  -- wires
  signal mclk_red_w, rd_clk_red_w : std_logic;
  
  -- registers
  signal mclk_d, mclk_q, rd_clk_d, rd_clk_q : std_logic;
  signal mclk1_d, rd_clk1_d : std_logic;
  signal mclk2_d, rd_clk2_d : std_logic;
  signal mclk4_d, rd_clk4_d : std_logic;    
  signal shift_q : std_logic_vector(15 downto 0);
 -- signal q_cntr : std_logic_vector(4 downto 0);

begin

  -- assign read_request
  rd_req_o <= rd_clk_red_w;

     
  p_shift_out : process(clk_100_i, rst_i)
  begin
    if (rst_i = '1') then 
      shift_q  <= (others => '0');
      mclk_q   <= '0';
      rd_clk_q <= '0';
    elsif (rising_edge(clk_100_i)) then 
      mclk_q  <= mclk_d;
      rd_clk_q <= rd_clk_d;

      if (data_vld_i = '1') then
        shift_q <= data_i;      
      elsif (mclk_red_w = '1') then 
        
        shift_q   <= shift_q(14 downto 0) & '0';
        aud_pwm_o <= shift_q(15);
      end if;
    end if;      
  end process p_shift_out;
  

  

      
  
    ------------------------------------------------------------------------------
  -- AUDIO CLOCKs
  -----------------------------------------------------------------------------
  
  -- rising edge detect
  --mclk2_red_w <= mclk2_d AND NOT mclk2_q;
  mclk_red_w  <= mclk_d AND NOT mclk_q;
  rd_clk_red_w <= rd_clk_d AND NOT rd_clk_q;
  
    -- Clock Multiplexers
  with play_speed_i select
    mclk_d <=
      mclk4_d when "10",
      mclk1_d when "01",
      mclk2_d when others;
      
 with play_speed_i select
    rd_clk_d <=
      rd_clk4_d when "10",
      rd_clk1_d when "01",
      rd_clk2_d when others;      
      
  
  -- 4 Mhz clock (fast)
  aud_clk_4MHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 13,
    g_max_width => 4)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => mclk4_d);
    
  rd_clk_250kHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 200,
    g_max_width => 8)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => rd_clk4_d);    

  -- 2 Mhz clock (normal)
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
    o_clk_div    => rd_clk2_d);    
    
    
  -- 1 Mhz clock (slow)
  aud_clk_1MHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 50,
    g_max_width => 6)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => mclk1_d);
    
  rd_clk_62p5kHz : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 800,
    g_max_width => 9)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => rd_clk1_d);    
    
    
end architecture rtl;