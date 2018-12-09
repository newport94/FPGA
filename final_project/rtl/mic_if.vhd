----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/28/2018 
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
  cntr_width_g : integer := 5)
  Port(
    clk_100_i : in    STD_LOGIC;
    rst_i     : in    STD_LOGIC;
    -- mic if signals
    m_data_i  : in    STD_LOGIC;
    m_clk_o   :   out STD_LOGIC;
    m_sel_o   :   out STD_LOGIC;
    -- record enable 
    rec_en_i  : in   STD_LOGIC;
    -- data out sigs
    sr_data_o :   out STD_LOGIC_VECTOR((sr_width_g - 1) downto 0);
    sr_vld_o  :   out STD_LOGIC);
end entity mic_if;

architecture rtl of mic_if is

constant unsigned SR_WIDTH_C(4 downto 0) := to_unsigned(sr_width_g, cntr_width_g);


-- registers
signal m_data_q, sr_data_q : STD_LOGIC_VECTOR((sr_width_g - 1) downto 0);
signal bit_cntr_q : unsigned((cntr_width_g - 1) downto 0);
signal sr_vld_q, mclk_q : STD_LOGIC;

-- wires
signal m_clk_red_w, cntr_rst_w, mclk_edge_w: STD_LOGIC;

begin

  -- wire up outputs
  sr_data_o <= sr_data_q;
  sr_vld_o  <= sr_vld_q;
  m_sel_o   <= '0';       -- select data on rising edge of mclk
  m_clk_o   <= 

  
  
  -------------------------------------------------------------------------
  -- SHIFT REGISTER/ PDM DESERIALIZER
  -------------------------------------------------------------------------
  
 -- shift register combinatorial logic (conditionals)
 cntr_rst_w  <= '1' when (bit_cntr_q = (SR_WIDTH_C - 1)) else '0';
 mclk_edge_w <= '1' when ((m_clk_red_w = '1') AND (rec_en_i = '1')) else '0';
 
  -- deserializer shift register for pdm data
  p_shift_in : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then 
      m_data_q <= (others => '0'); 
    elsif (rising_edge(clk_i)) then 
      if (mclk_edge_w = '1') then 
        m_data_q <= m_data_q((sr_width_g - 2) downto 0) & m_data_i;
      end if;
    end if;
  end process p_shift_in;
  
  -- bit counter for shift register
  p_cnt_bits : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then 
      bit_cntr_q <= (others => '0');
      sr_data_q  <= (others => '0');
      sr_vld_q   <= '0';
    elsif (rising_edge(clk_i)) then 
      if (mclk_edge_w = '1') then 
        if (cntr_rst_w = '1') then 
          bit_cntr_q <= (others => '0');        
          sr_vld_q   <= '1';
          sr_data_q  <= m_data_q;
        else
          sr_vld_q <= '0';
          bit_cntr_q <= bit_cntr_q + 1;
        end if;
      end if;
    end if;                              
  end process p_cnt_bits;
  
  
  
  ------------------------------------------------------------------------------
  -- PDM CLOCK
  -----------------------------------------------------------------------------
  
  -- pdm clock combinatorial logic
  mclk_rst_w = '1' when (mclk_cntr_q = 
  
  -- generate pdm clock
  p_mclk : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then 
      mclk_q      <= '0';
      mclk_cntr_q <= (others => '0');
    elsif (rising_edge(clk_i)) then 
      if (mclk_rst_w = '1') then 
        mclk_q      <= not mclk_q;
        mclk_cntr_q <= (others => '0');
      else
        mclk_cntr_q <= mclk_cntr_q + 1;
      end if;
    end if;

  end process p_mclk;







end architecture rtl;

