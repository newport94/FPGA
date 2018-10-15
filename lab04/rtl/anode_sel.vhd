----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/15/2018 
-- Module Name:    anode_select
-- Project Name:   Lab02
-- Target Device:  Xilinx Artix-7 XC7A100T-1CSG324C
--
-- Description:  Selects current anode based off of 1 kHz pulse.  
--               

-- Seven seg display chars are numbered as follows
--      7     6     5      4        3     2     1     0
--  --------------------------- --------------------------
--  |   --    --    --    --  | |  --    --    --    --  |
--  |  |  |  |  |  |  |  |  | | | |  |  |  |  |  |  |  | |
--  |   --    --    --    --  | |  --    --    --    --  |
--  |  |  |  |  |  |  |  |  | | | |  |  |  |  |  |  |  | |
--  |   --    --    --    --  | |  --    --    --    --  |
--  --------------------------- --------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity anode_sel is 
  Port(
    i_clk    : in    std_logic;                    -- 100 MHz clk
    i_rst    : in    std_logic;                    -- asynchronous reset
    i_pulse  : in    std_logic;                    -- 1 kHz "pulse"
    o_an_sel :   out std_logic_vector(2 downto 0)); -- select 0 through 7
end entity anode_sel;

architecture rtl of anode_sel is 

signal   d_cntr, q_cntr : unsigned(2 downto 0);
signal   synchReset     : std_logic;
constant c_max_cnt      : unsigned(2 downto 0) := "111";

begin

  p_sel: process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_cntr <= (others => '0');
    elsif (rising_edge(i_clk)) then 
      if (synchReset = '1') then 
        q_cntr <= (others => '0');
      else
        q_cntr <= d_cntr;
      end if; 
    end if;      
  end process p_sel;
  
  synchReset <= '1' when q_cntr = c_max_cnt and i_pulse = '1' else '0';
  d_cntr <= q_cntr + 1 when i_pulse = '1' else q_cntr;
 
  o_an_sel   <= std_logic_vector(q_cntr);

end architecture rtl;
    