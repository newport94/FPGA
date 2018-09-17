----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   09/15/2018 
-- Module Name:   tb_char_shift_reg
-- Project Name:  Lab02
--
-- Description:  testbench for 8 character shift register entity
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_char_shift_reg entity
entity tb_char_shift_reg is
end entity tb_char_shift_reg;

architecture tb of tb_char_shift_reg is 
  constant c_max_cnt : unsigned(16 downto 0) := '1' & x"86A0";  -- hex for 100,000
  signal clk        : STD_LOGIC;
  signal rst        : STD_LOGIC;
  signal w_pulse    : STD_LOGIC;
  signal test_sig   : STD_LOGIC_VECTOR(3 downto 0);
  
  type t_sr8x4 is array (7 downto 0) of std_logic_vector(3 downto 0);
  signal shift_reg : t_sr8x4;
  
begin

  test_sig <= x"0", x"F" after 60 ns, x"0" after 100 ns;

  UUT: entity work.char_shift_reg(rtl)
    Port map(i_clk   => clk,
             i_rst   => rst,
             i_en    => w_pulse,
             i_char  => test_sig,
             o_char0 => shift_reg(0),
             o_char1 => shift_reg(1),
             o_char2 => shift_reg(2),
             o_char3 => shift_reg(3),
             o_char4 => shift_reg(4),
             o_char5 => shift_reg(5),
             o_char6 => shift_reg(6),
             o_char7 => shift_reg(7));
    
  PGEN: entity work.pulse_generator(rtl)
    Port map(
      i_clk     => clk,
      i_reset   => rst,
      i_max_cnt => c_max_cnt,
      o_pulse   => w_pulse);
  -- set reset high at start
  rst <= '0', '1' after 5 ns, '0' after 50 ns;

  -- 100 MHz clock (10 ns period)
  p_clk: process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process p_clk;



end architecture tb;
