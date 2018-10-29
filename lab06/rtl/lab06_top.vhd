----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/28/2018 
-- Module Name:   lab06_top
-- Project Name:  Lab06
--
-- Description:  top level entity  for lab 06

-- BTNC is the overall reset for all sequential logic
--
-- • SW(5:3) will be used to set the volume level of the output
--    o ‘111’ will be maximum volume
--    o ‘110’ will be half the max volume
--    o ‘101’ will be one fourth max volume
--    o …
--    o ‘000’ will be 1/128 max volume
--
-- • SW(2:0) will be used to set the output frequency of the sine wave
--    o ‘000’ will be 0Hz or DC **special case for counter!
--    o ‘001’ will be 500Hz
--    o ‘010’ will be 1000Hz
--    o ‘011’ will be 1500Hz
--    o ‘100’ will be 2000Hz
--    o ‘101’ will be 2500Hz
--    o ‘110’ will be 3000Hz
--    o ‘111’ will be 3500Hz
--
-- SW(15) will be used to turn on and off the amplifier network
--
-- Upper 4 7seg display volume (0, 1, 2, …, 7 where is max)
-- Lower 4 7seg display frequency in decimal format
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work. all;

entity lab06_top is 
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(15 downto 0);    -- Switch [5..3] = volume, SW[2..0] = frequency, SW[15] = audio output enable
    BTNC      : in    STD_LOGIC;                       -- overall reset
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0);
    AUD_SD    :   out STD_LOGIC);                     -- audio output enable
end entity lab06_top;


architecture rtl of lab06_top is 

  COMPONENT dds_compiler_0
    PORT (
      aclk : IN STD_LOGIC;                                      -- 100 MHz clock input
      s_axis_phase_tvalid : IN STD_LOGIC;                       -- set to '1'
      s_axis_phase_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);     -- output of 8-bit phase accumulator block
      m_axis_data_tvalid : OUT STD_LOGIC;                       -- ignore
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)     -- 16-bit sine value at the current position in the sine lookup table
    );
  END COMPONENT;



begin




  your_instance_name : dds_compiler_0
    PORT MAP (
      aclk => CLK100MHZ,
      s_axis_phase_tvalid => '1',
      s_axis_phase_tdata => s_axis_phase_tdata,
      m_axis_data_tvalid => open,
      m_axis_data_tdata => m_axis_data_tdata
    );










end architecture rtl;
