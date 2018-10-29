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
use work.all;

entity lab06_top is 
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(15 downto 0);    -- Switch [5..3] = volume, SW[2..0] = frequency, SW[15] = audio output enable
    BTNC      : in    STD_LOGIC;                       -- overall reset
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0);
    AUD_PW    :   out STD_LOGIC;                      -- audio pwm output
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
    
  component pulse_gen
    Port(
      i_clk     : in    STD_LOGIC; -- 100 MHz clock
      i_rst     : in    STD_LOGIC; -- asynchronous reset
      i_max_val : in    STD_LOGIC_VECTOR(9 downto 0);
      o_pulse   :   out STD_LOGIC);
  end component;  
    
 constant THETA_MAX_K : unsigned(7 downto 0) := to_unsigned(255, 8);
    
 signal sw_freq_w, sw_vol_w : std_logic_vector(2 downto 0);
 signal max_cnt_w : unsigned(9 downto 0);
 signal phase_inc_w, theta_rst_w : std_logic;      
 signal theta_q : unsigned(7 downto 0);
 signal sin_w : std_logic_vector(15 downto 0);
 signal sin_vol_w : std_logic_vector(15 downto 0);


begin

  AUD_SD <= SW(15);
  
  sw_freq_w <= SW(2 downto 0);
  sw_vol_w  <= SW(5 downto 3);
  vol_slice_w <= vol_w(15 downto 6);  

  theta_rst_w <= '1' when (theta_q = THETA_MAX_K) else '0';
  
  with sw_freq_w select
    max_cnt_w <=
      to_unsigned(781, 10) when "001",
      to_unsigned(391, 10) when "010",
      to_unsigned(260, 10) when "011",
      to_unsigned(195, 10) when "100",
      to_unsigned(156, 10) when "101",
      to_unsigned(130, 10) when "110",
      to_unsigned(111, 10) when "111",
      to_unsigned(0  , 10) when others; 
        
   with sw_vol_w select
     sin_vol_w <=
       shift_right(sin_w, 7) when "000",
       shift_right(sin_w, 6) when "001",
       shift_right(sin_w, 5) when "010",
       shift_right(sin_w, 4) when "011",
       shift_right(sin_w, 3) when "100",
       shift_right(sin_w, 2) when "101",
       shift_right(sin_w, 1) when "110",
       sin_w                 when others;
           
        
        -- make sure to do invert bit thingy from assignment


  S_phase_acc : process(CLK100MHZ, BTNC)
  begin
    if (BTNC = '1') then
      theta_q <= (others => '0');
    elsif (rising_edge(CLK100MHZ)) then   
      if (theta_rst_w = '1') then 
        theta_q <= (others => '0');
      elsif (phase_inc_w = '1') then
        theta_q <= theta_q + 1;
      end if;
    end if;    
  end process S_phase_acc;



   U_PHASE_INC : pulse_gen
    Port map(
      i_clk     => CLK100MHZ, -- 100 MHz clock
      i_rst     => BTNC, -- asynchronous reset
      i_max_val => std_logic_vector(max_cnt_w),
      o_pulse   => phase_inc_w);    
 

  U_DDS_LUT : dds_compiler_0
    PORT MAP (
      aclk => CLK100MHZ,
      s_axis_phase_tvalid => '1',
      s_axis_phase_tdata => std_logic_vector(theta_q),
      m_axis_data_tvalid => open,
      m_axis_data_tdata => sin_w
    );


end architecture rtl;
