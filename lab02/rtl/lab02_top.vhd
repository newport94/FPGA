----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    09/16/2018 
-- Module Name:    lab02_top
-- Project Name:   Lab02
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  Top level entity for lab 02.  Implements a time multiplexed 
--               seven segment display for all 8 digits.  Moves in time at rate 
--               of 1 Hz from right to left
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity lab02_top is 
  Port(
    i_CLK100MHZ : in    STD_LOGIC;
    i_BTNC      : in    STD_LOGIC;
    i_SW        : in    STD_LOGIC_VECTOR(3 downto 0);
--  o_LED       :   out STD_LOGIC_VECTOR(15 downto 0);
    o_SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);
    o_AN        :   out STD_LOGIC_VECTOR(7 downto 0));
end entity lab02_top;

architecture rtl of lab02_top is
  -- constants 
  constant c_max_cnt : unsigned(26 downto 0) := "101" & x"F5E100";  -- hex for 100,000,000 --> 1 Hz pulse
  
  -- wires 
  signal w_shift_en : STD_LOGIC;
  signal w_char0, w_char1, w_char2, w_char3, w_char4, w_char5, w_char6, w_char7 : STD_LOGIC_VECTOR(3 downto 0);


begin 

  PGEN_1Hz: entity work.pulse_gen_1Hz(rtl)
    Port map(
      i_clk     => i_CLK100MHZ,
      i_reset   => i_BTNC,
      i_max_cnt => c_max_cnt,
      o_pulse   => w_shift_en);
      
  CHAR_SR: entity work.char_shift_reg(rtl)
    Port map(
      i_clk   => i_CLK100MHZ,
      i_rst   => i_BTNC,
      i_en    => w_shift_en,
      i_char  => i_SW,
      o_char0 => w_char0,
      o_char1 => w_char1,
      o_char2 => w_char2,
      o_char3 => w_char3,
      o_char4 => w_char4,
      o_char5 => w_char5,
      o_char6 => w_char6,
      o_char7 => w_char7);
      

  SEG7_CNTRL: entity work.seg7_controller(rtl)
    Port map( 
      i_clk   => i_CLK100MHZ,   -- STD_LOGIC;                     
      i_rst   => i_BTNC,        -- STD_LOGIC;                     
      i_char0 => w_char0,       -- STD_LOGIC_VECTOR(3 downto 0)  
      i_char1 => w_char1,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char2 => w_char2,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char3 => w_char3,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char4 => w_char4,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char5 => w_char5,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char6 => w_char6,       -- STD_LOGIC_VECTOR(3 downto 0)
      i_char7 => w_char7,       -- STD_LOGIC_VECTOR(3 downto 0)
      o_AN    => o_AN,          -- STD_LOGIC_VECTOR(7 downto 0)
      o_EN    => o_SEG7_CATH);  -- STD_LOGIC_VECTOR(7 downto 0)               

end architecture rtl;