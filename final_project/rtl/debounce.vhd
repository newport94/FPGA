
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

--constant k_max_val    : unsigned(23 downto 0) := to_unsigned(10000000, 24); -- 100 ms assuming a 100 MHz clk
constant k_max_val    : unsigned(6 downto 0) := "110" & x"4";  -- 1 us assuming a 100 MHz clk (SIM ONLY)
signal   q_ctr : unsigned(24 downto 0);

signal w_ctr_clr, w_ctr_en : std_logic;
signal d_db, q_db, w_red : std_logic;

begin
 
  -- rising edge detect
  o_db <= d_db AND NOT q_db;  
  
  C_Debounce : process(i_pb, q_ctr)
  begin
    d_db      <= '0';
    w_ctr_clr <= '0';
    w_ctr_en  <= '0';
    if (i_pb = '1') then
      if (q_ctr < k_max_val) then
        w_ctr_en <= '1';
      else
        d_db <= '1';
      end if;
    else
      w_ctr_clr <= '1';
    end if;
     
  end process C_Debounce;
  
  

  --- sequential process
  S_Clk : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      q_ctr <= (others => '0');  -- asynchronous reset
    elsif (rising_edge(i_clk)) then
      
      q_db <= d_db;
      
      if (w_ctr_clr = '1') then
        q_ctr <= (others => '0');
      elsif (w_ctr_en = '1') then
        q_ctr <= q_ctr + 1;
      end if;
        
    end if;
  end process S_Clk;


end architecture rtl;
    