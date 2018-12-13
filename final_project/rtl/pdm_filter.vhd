----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/28/2018 
-- Module Name:   pdm_filter
-- Project Name:  Final Project
--
-- Description: implements decimating CIC filter with R = 32
-- Also has FIR decimating compensation filter with R = 2

-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;


entity pdm_filter is
  Port(
    clk_100_i    : in    STD_LOGIC;
    rst_i        : in    STD_LOGIC;
    pdm_word_i   : in    STD_LOGIC_VECTOR(15 downto 0);
    word_vld_i   : in    STD_LOGIC;
    fir_data_o   :   out STD_LOGIC_VECTOR(15 downto 0);
    fir_vld_o    :   out STD_LOGIC;
    rdy_to_fir_i : in    STD_LOGIC);
end entity pdm_filter;


architecture rtl of pdm_filter is

COMPONENT cic_dec_64
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    event_halted : OUT STD_LOGIC
  );
  END COMPONENT;    
  
  COMPONENT fir_comp_dec2
    PORT (
      aclk               : IN    STD_LOGIC;
      s_axis_data_tvalid : IN    STD_LOGIC;
      s_axis_data_tready :   OUT STD_LOGIC;
      s_axis_data_tdata  : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_data_tvalid :   OUT STD_LOGIC;
      m_axis_data_tready : IN    STD_LOGIC;
      m_axis_data_tdata  :   OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;  
  
  -- wires
  signal cic_data_out : std_logic_vector(31 downto 0);
  signal fir_data_out : std_logic_vector(15 downto 0);
  signal cic_vld_out, fir_to_cic_rdy, fir_vld_out : std_logic;


begin

  fir_data_o <= cic_data_out(31 downto 16);
  fir_vld_o  <= cic_vld_out;

  U_CIC_32kHz: cic_dec_64
  PORT MAP (
    aclk               => clk_100_i,
    s_axis_data_tdata  => pdm_word_i,
    s_axis_data_tvalid => word_vld_i,
    s_axis_data_tready => open,
    m_axis_data_tdata  => cic_data_out,
    m_axis_data_tvalid => cic_vld_out,
    m_axis_data_tready => rdy_to_fir_i,--fir_to_cic_rdy,
    event_halted       => open);

  -- U_FIR_16kHz: fir_comp_dec2
  -- PORT MAP (
    -- aclk               => clk_100_i,
    -- s_axis_data_tvalid => cic_vld_out,
    -- s_axis_data_tready => fir_to_cic_rdy,
    -- s_axis_data_tdata  => cic_data_out,
    -- m_axis_data_tvalid => fir_vld_o,
    -- m_axis_data_tready => rdy_to_fir_i,
    -- m_axis_data_tdata  => fir_data_o);


end architecture rtl;