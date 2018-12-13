----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   12/09/2018 
-- Module Name:   mic_if
-- Project Name:  Final Project
--
-- Description: interface for microphone. Generates clock, selects channel,
-- implements shift register to deserialize data
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity mic_if is
  Generic(
  sr_width_g   : integer := 16;
  cntr_width_g : integer := 5);
  Port(
    clk_100_i : in    STD_LOGIC;
    rst_i     : in    STD_LOGIC;
    -- mic if signals
    m_data_i  : in    STD_LOGIC;
    m_clk_o   :   out STD_LOGIC;
    m_sel_o   :   out STD_LOGIC;
    -- record enable 
    rec_strobe_w_i  : in   STD_LOGIC;
    -- data out sigs
    sr_data_o :   out STD_LOGIC_VECTOR((sr_width_g - 1) downto 0);
    sr_vld_o  :   out STD_LOGIC);
end entity mic_if;

architecture rtl of mic_if is

constant  SR_WIDTH_C : unsigned(4 downto 0) := to_unsigned(sr_width_g, cntr_width_g);


-- registers
signal m_data_q : STD_LOGIC_VECTOR((sr_width_g - 1) downto 0);
signal bit_cntr_q : unsigned((cntr_width_g - 1) downto 0);
signal mclk_q, mclk_d, cntr_rst_q : STD_LOGIC;

-- wires
signal mclk_red_w, cntr_rst_d, mclk_edge_w: STD_LOGIC;


begin

  -- wire up outputs
  sr_vld_o  <= cntr_rst_q;
  m_sel_o   <= '0';       -- select data on rising edge of mclk
  m_clk_o   <= mclk_d;
  
  
  
  -------------------------------------------------------------------------
  -- SHIFT REGISTER/ PDM DESERIALIZER
  -------------------------------------------------------------------------
  
 -- shift register combinatorial logic (conditionals)
 cntr_rst_d  <= '1' when (bit_cntr_q = (SR_WIDTH_C)) else '0';
 --mclk_edge_w <= '1' when ((mclk_red_w = '1') AND (rec_en_i = '1')) else '0';
  mclk_edge_w <= mclk_red_w;
 
  -- deserializer shift register for pdm data
  p_shift_in : process(clk_100_i, rst_i)
  begin
    if (rst_i = '1') then 
      m_data_q <= (others => '0'); 
    elsif (rising_edge(clk_100_i)) then 
      if (mclk_edge_w = '1') then 
        m_data_q <= m_data_q((sr_width_g - 2) downto 0) & m_data_i;
      end if;
    end if;
  end process p_shift_in;
  
  -- bit counter for shift register
  p_cnt_bits : process(clk_100_i, rst_i)
  begin
    if (rst_i = '1') then 
      bit_cntr_q <= (others => '0');
      mclk_q <= '0';
      cntr_rst_q <= '0';
    elsif (rising_edge(clk_100_i)) then 
      if (cntr_rst_d = '1') then 
        bit_cntr_q <= (others => '0');   
        sr_data_o  <= m_data_q;
      
      elsif (mclk_edge_w = '1') then 
        bit_cntr_q <= bit_cntr_q + 1;
      end if;
      mclk_q <= mclk_d;      
      cntr_rst_q <= cntr_rst_d;  
    end if;                            
  end process p_cnt_bits;
  

  ------------------------------------------------------------------------------
  -- PDM CLOCK 2 MHz
  -----------------------------------------------------------------------------
  
  -- rising edge detect
  mclk_red_w <= mclk_d AND NOT mclk_q;
  
  clk_div : entity work.clk_div(rtl)
  Generic Map(
    g_max_cnt   => 25,
    g_max_width => 5)
  Port Map(
    i_clk        => clk_100_i,
    i_reset      => rst_i,
    o_clk_div    => mclk_d);

    
    
end architecture rtl;

