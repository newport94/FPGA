----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   11/10/2018 
-- Module Name:   accel_spi_rw2_tb
-- Project Name:  Lab04
--
-- Description:  acelleromteter read/write spi interface second attempt testbench
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity accel_spi_rw2_tb is
end entity accel_spi_rw2_tb;

architecture tb of accel_spi_rw2_tb is

signal clk, mode, rst, done, MOSI, CS, SCLK, MISO : std_logic;
signal dout : std_logic_vector(7 downto 0);
signal din  : std_logic_vector(23 downto 0);

begin

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

  -- main process 
  process
  begin
    mode <= '0';
    din <= (others => '0');
    MISO <= '0';
    rst <= '0', '1' after 1 ns, '0' after 5 ns;
    wait for 240 ns; 
    mode <= '1';
    din <= x"AA2B25";
    -- wait for 20 ns;
    -- MISO <= '1';
    -- wait for 100 ns;
    -- MISO <= '0';
    -- wait for 2 ns;
    -- MISO <= '1';
    -- wait for 2 ns;
    -- MISO <= '0';
    wait for 3364 ns;
    MISO <= '1';
    wait for 200 ns;
    MISO <= '0';
    wait for 200 ns;
    MISO <= '1';
    wait for 200 ns;
    MISO <= '0';
    wait for 200 ns;
    MISO <= '1';
    wait for 200 ns;
    MISO <= '0';
    wait for 200 ns;
    MISO <= '1';
    wait for 200 ns;
    MISO <= '0';
    wait for 200 ns;
    
    wait;

  end process;

 U_UUT: entity work.accel_spi_rw2(rtl)
  Port map(
    i_clk  => clk,
    i_mode => mode,
    i_rst  => rst,
    i_din  => din,
    o_dout => dout,
    o_done => done,
    o_MOSI => MOSI,
    o_CS   => CS,
    o_SCLK => SCLK,
    i_MISO => MISO);

end architecture tb;