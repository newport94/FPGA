
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity one_pps is 
  Port(
    clk : in std_logic;
    rst : in std_logic;
    pps : out std_logic
  );

end entity one_pps;
  
architecture rtl of one_pps is

--constant max_val : unsigned(25 downto 0) := "10" & x"FAF080";
constant max_val : unsigned(3 downto 0) := x"F";
signal  cntr : unsigned(25 downto 0);
signal cntr_rst : std_logic;
  
begin  
  
p_pgen: process(clk,rst)
begin
  if (rst = '1') then  -- asynchronous reset
    cntr <= (others => '0');
  elsif (rising_edge(clk)) then
    if (cntr_rst = '1') then
      cntr <= (others => '0');
    else
      cntr <= cntr + 1;
    end if;
  end if;
end process;

cntr_rst <= '1' when cntr = max_val else '0';
pps <= cntr_rst;



end architecture rtl;