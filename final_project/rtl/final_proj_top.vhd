----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/28/2018 
-- Module Name:   final_proj_top
-- Project Name:  Final Project
--
-- Description:  top level entity  for microphone playback final project

-- BTNC is the overall reset for all sequential logic
--


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity final_proj_top is
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(15 downto 0);    -- Switch [5..3] = volume, SW[2..0] = frequency, SW[15] = audio output enable
    BTNC      : in    STD_LOGIC;                       -- overall reset
    -- seven seg display
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0);
    -- microphone
    M_CLK     :   out STD_LOGIC; 
    M_DATA    : in    STD_LOGIC;
    M_LRSEL   :   out STD_LOGIC;
    -- Audio jack signals
    AUD_PWM   :   out STD_LOGIC;                      -- audio pwm output
    AUD_SD    :   out STD_LOGIC);                     -- audio output enable
end entity final_proj_top;


architecture rtl of final_proj_top is


begin




end architecture rtl;