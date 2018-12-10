----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   12/09/2018 
-- Module Name:   tb_mic_if
-- Project Name:  Lab03
--
-- Description:  testbench for microphone interface
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_mic_if entity
entity tb_mic_if is
end entity tb_mic_if;

architecture tb of tb_mic_if is 


component mic_if is
  Generic(
    sr_width_g   : integer;
    cntr_width_g : integer);
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
end component;


signal clk   : STD_LOGIC;
signal rst   : STD_LOGIC;

signal mic_clk, mic_sel, rec_enable, pdm_vld, mdata : std_logic;
signal pdm_data : std_logic_vector(15 downto 0);



begin


  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  rec_enable <= '0', '1' after 200 ns;
  mdata <= '1', '0' after 65 us;
  
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;        -- 100 MHz clock (10 ns period)       
  
  
  
  UUT:  mic_if
  Generic Map(
    sr_width_g    => 16, 
    cntr_width_g  => 5)
  Port Map(
    clk_100_i => clk,
    rst_i     => rst,
    -- mic if   
    m_data_i  => mdata,
    m_clk_o   => mic_clk,
    m_sel_o   => mic_sel,
    -- record 
    rec_en_i  => rec_enable,
    -- data out
    sr_data_o => pdm_data,
    sr_vld_o  => pdm_vld);
      
  
end architecture tb;