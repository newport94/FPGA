----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/13/2018 
-- Module Name:   sipo
-- Project Name:  Lab04
--
-- Description:  serial in parallel out module
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sipo is 
  Generic(
    g_reg_width  : integer := 8;
    g_cntr_width : integer := 4);
  Port(
    i_clk   : in    STD_LOGIC;
    i_rst   : in    STD_LOGIC;
    i_sin   : in    STD_LOGIC;
    i_en    : in    STD_LOGIC;
    o_pout  :   out STD_LOGIC_VECTOR((g_reg_width - 1) downto 0);
    o_vld   :   out STD_LOGIC);
end entity sipo;

architecture rtl of sipo is

signal q_cntr : unsigned((g_cntr_width - 1) downto 0);
constant k_cntr_max : unsigned((g_cntr_width - 1) downto 0) := to_unsigned((g_reg_width), g_cntr_width);

signal q_temp : std_logic_vector((g_reg_width - 1) downto 0);

begin

  p_reg_sdata : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      q_temp <= (others => '0');
      q_cntr <= (others => '0');
      o_pout <= (others => '0');
      o_vld  <= '0';
      
    elsif (rising_edge(i_clk)) then
      if (i_en = '1') then
        if (q_cntr = k_cntr_max) then
          q_cntr <= (others => '0');
          o_pout <= q_temp;
          o_vld  <= '1';
        else
          q_cntr <= q_cntr + 1;
          q_temp((g_reg_width - 1) downto 1) <= q_temp((g_reg_width - 2) downto 0);
          q_temp(0) <= i_sin;
        end if;
      end if;
    end if;
  end process p_reg_sdata;

end architecture rtl; 