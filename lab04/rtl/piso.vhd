----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/13/2018 
-- Module Name:   piso
-- Project Name:  Lab04
--
-- Description:  parallel in serial out module
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity piso is 
  Generic(
    g_width : integer := 24);
  Port(
    i_clk   : in    STD_LOGIC;
    i_rst   : in    STD_LOGIC;
    i_din   : in    STD_LOGIC_VECTOR ((g_width - 1) downto 0);
    i_mode  : in    STD_LOGIC_VECTOR(1 downto 0);
    o_sdout :   out STD_LOGIC);
end entity piso;

architecture rtl of piso is 

signal q_sr : std_logic_vector((g_width - 1) downto 0);

begin

  p_sr:  process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      o_sdout <= '0';
      q_sr    <= (others => '0');
    elsif (rising_edge(i_clk)) then
      case i_mode is
        when "00" =>    -- no op
          null;
          
        when "01" =>    -- load 
          q_sr <= i_din;
          
        when "10" =>    -- shift left for msb out
          o_sdout <= q_sr(g_width - 1);      
          q_sr((g_width - 1) downto 1) <= q_sr((g_width - 2) downto 0);  
          
        when others =>  -- no op
          null;
          
      end case;
    end if;
  end process p_sr;

end architecture rtl;