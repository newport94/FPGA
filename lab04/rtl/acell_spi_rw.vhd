----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/07/2018 
-- Module Name:   acell_spi_rw
-- Project Name:  Lab04
--
-- Description:  acelleromteter read/write spi interface
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity acell_spi_rw is
  Port(
    i_clk    : in    STD_LOGIC;
    i_mode   : in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
    i_rst    : in    STD_LOGIC;
    o_DATA_X :   out STD_LOGIC_VECTOR(7 downto 0); -- values read from acelleromteter
    o_DATA_Y :   out STD_LOGIC_VECTOR(7 downto 0);
    o_DATA_Z :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_AD  :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_1D  :   out STD_LOGIC_VECTOR(7 downto 0);
    o_MOSI   :   out STD_LOGIC; -- SPI signals for accelleromteter
    o_CS     :   out STD_LOGIC;
    o_SCLK   :   out STD_LOGIC;
    i_MISO   : in    STD_LOGIC);
end entity acell_spi_rw;

architecture rtl of acell_spi_rw is

-- declare enumerated type for state machine
type state_type is (STANDBY, MEAS, ID_AD, ID_1D, DATA_X, DATA_Y, DATA_Z);
signal curr_state, next_state : state_type;


begin
  
p_FSM : process(curr_state)


end process p_FSM;



-- clk process
--   if new
--      dout_Reg <= new
--  elsif shifting
--     dout_reg <= dout_reg(7 downto 1)
--     dout <= dout_reg(0)

  
 -- clock divider for 1 MHz clock
 
 



end architecture rtl;