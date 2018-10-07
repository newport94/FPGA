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

begin

  




end architecture rtl;