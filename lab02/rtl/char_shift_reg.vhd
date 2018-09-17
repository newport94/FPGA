----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/16/2018 
-- Module Name:    char_shift_rego
-- Project Name:   Lab02
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  8 character shift register for 7 segment display
----------------------------------------------------------------------------------  
  
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;  
  
entity char_shift_reg is
  Port(
    i_clk   : in    STD_LOGIC;
    i_rst   : in    STD_LOGIC;
    i_en    : in    STD_LOGIC;
    i_char  : in    STD_LOGIC_VECTOR(3 downto 0);
    o_char0 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char1 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char2 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char3 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char4 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char5 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char6 :   out STD_LOGIC_VECTOR(3 downto 0);
    o_char7 :   out STD_LOGIC_VECTOR(3 downto 0));
end entity char_shift_reg;

architecture rtl of char_shift_reg is

type t_sr8x4 is array (7 downto 0) of std_logic_vector(3 downto 0);

signal shift_reg : t_sr8x4;

begin 

  p_SR : process(i_clk, i_rst)
  begin
     if i_rst = '1' then 
      shift_reg <= (others => (others =>'0'));
     elsif (rising_edge(i_clk)) then 
      if i_en = '1' then 
        shift_reg(7 downto 1) <= shift_reg(6 downto 0);
        shift_reg(0)          <= i_char;
      end if;
    end if;
  end process p_SR;
  
  o_char0 <= shift_reg(0);
  o_char1 <= shift_reg(1);
  o_char2 <= shift_reg(2);
  o_char3 <= shift_reg(3);
  o_char4 <= shift_reg(4);
  o_char5 <= shift_reg(5);
  o_char6 <= shift_reg(6);
  o_char7 <= shift_reg(7);
  
end architecture rtl;