
----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/18/2018 
-- Module Name:    debounce
-- Project Name:   Lab03
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  Debounces the bush puttons on the Nexys 4 board
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity debounce is 
  Port(
    i_clk : in    std_logic;   -- 100 MHz clk
    i_rst : in    std_logic;
    i_pb  : in    std_logic;
    o_db  :   out std_logic);
end entity debounce;
  
architecture rtl of debounce is 

constant k_max_val    : unsigned(18 downto 0) := "111" & x"A120";  -- 5 ms assuming a 100 MHz clk 7A120
-- constant k_max_val    : unsigned(6 downto 0) := "110" & x"4";  -- 1 us assuming a 100 MHz clk (SIM ONLY)
signal   q_ctr, d_ctr : unsigned(18 downto 0);

signal w_ctr_clr, w_ctr_en : std_logic;


begin

  d_ctr <= q_ctr + 1;

  S_Clk : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      q_ctr <= (others => '0');  -- asynchronous reset
    elsif (rising_edge(i_clk)) then
      if (w_ctr_clr = '1') then
        q_ctr <= (others => '0');
      elsif (w_ctr_en = '1') then
        q_ctr <= d_ctr;
      end if;
    end if;
  end process S_Clk;
  
  C_Debounce : process(i_pb, q_ctr)
  begin
    o_db      <= '0';
    w_ctr_clr <= '0';
    w_ctr_en  <= '0';
    if (i_pb = '1') then
      if (q_ctr < k_max_val) then
        w_ctr_en <= '1';
      else
        o_db <= '1';
      end if;
    else
      w_ctr_clr <= '1';
    end if; 
  end process C_Debounce;


end architecture rtl;
    