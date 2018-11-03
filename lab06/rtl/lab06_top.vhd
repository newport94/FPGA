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
    AUD_PWM   :   out STD_LOGIC;                      -- audio pwm output
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
  
  component seg7_controller
  Port ( i_clk   : in     STD_LOGIC;                     -- 100 MHz clock
         i_rst   : in     STD_LOGIC;                     -- asynchronous reset
         i_char0 : in     STD_LOGIC_VECTOR(3 downto 0);  -- the 8 hex characters to display
         i_char1 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char2 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char3 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char4 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char5 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char6 : in     STD_LOGIC_VECTOR(3 downto 0);
         i_char7 : in     STD_LOGIC_VECTOR(3 downto 0);
         o_AN    :    out STD_LOGIC_VECTOR(7 downto 0);
         o_EN    :    out STD_LOGIC_VECTOR(7 downto 0));  -- encoded character                 
  end component;
  
  
  component pwm_gen
    Generic( 
      pwm_resolution : integer);
    Port(
      clk_i        : in    STD_LOGIC;
      rst_i        : in    STD_LOGIC;
      duty_cycle_i : in    STD_LOGIC_VECTOR((pwm_resolution - 1) downto 0);
      pwm_o        :   out STD_LOGIC    
    );
  end component;  
    
 constant THETA_MAX_K : unsigned(7 downto 0) := to_unsigned(255, 8);
    
 signal sw_freq_w, switch_vol_w : std_logic_vector(2 downto 0);
 signal max_cnt_w : unsigned(9 downto 0);
 signal phase_inc_w, theta_rst_w, pwm_w : std_logic;      
 signal theta_q : unsigned(7 downto 0);
 signal freq_disp_w, dds_in_w : std_logic_vector(7 downto 0);
 signal sin_w : std_logic_vector(15 downto 0);
 signal sin_vol_w, sin_ls_w : std_logic_vector(9 downto 0);

begin
  
  -- assign outputs
  AUD_SD <= SW(15);
  AUD_PWM <= pwm_w;
  
  sw_freq_w <= SW(2 downto 0);
  switch_vol_w  <= SW(5 downto 3);
  sin_ls_w <= (NOT sin_w(15)) & sin_w(14 downto 6);

  theta_rst_w <= '1' when (theta_q = THETA_MAX_K) else '0';
  
  dds_in_w <= x"80" when (sw_freq_w = "000") else std_logic_vector(theta_q);
  
  with sw_freq_w select
    max_cnt_w <=
      to_unsigned(781, 10) when "001",  -- 500 Hz
      to_unsigned(391, 10) when "010",  -- 1000
      to_unsigned(260, 10) when "011",  -- 1500
      to_unsigned(195, 10) when "100",  -- 2000
      to_unsigned(156, 10) when "101",  -- 2500
      to_unsigned(130, 10) when "110",  -- 3000
      to_unsigned(111, 10) when "111",  -- 3500
      to_unsigned(0  , 10) when others; -- DC
      
  with sw_freq_w select
    freq_disp_w <=
      x"05" when "001",  -- 0500 Hz
      x"10" when "010",  -- 1000
      x"15" when "011",  -- 1500
      x"20" when "100",  -- 2000
      x"25" when "101",  -- 2500
      x"30" when "110",  -- 3000
      x"35" when "111",  -- 3500
      x"00" when others; -- DC      
        
   with switch_vol_w select
     sin_vol_w <=
       std_logic_vector(shift_right(unsigned(sin_ls_w), 7)) when "000",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 6)) when "001",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 5)) when "010",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 4)) when "011",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 3)) when "100",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 2)) when "101",
       std_logic_vector(shift_right(unsigned(sin_ls_w), 1)) when "110",
       sin_ls_w                 when others;
           
        
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
  
  
  
  U_PWM_GEN: pwm_gen
    Generic map( 
      pwm_resolution => 10)
    Port map(
      clk_i        => CLK100MHZ,
      rst_i        => BTNC,
      duty_cycle_i => sin_vol_w,
      pwm_o        => pwm_w);   
  
   -- 7 seg display
   -- display frequency in decimal on lower 4
   -- volume level on upper 4 as (min) 0, 1, 2, ... 7 (max)
  U_SEG7 : seg7_controller
    Port map( 
      i_clk   => CLK100MHZ,  
      i_rst   => BTNC,  
      i_char0 => x"0", 
      i_char1 => x"0",
      i_char2 => freq_disp_w(3 downto 0),
      i_char3 => freq_disp_w(7 downto 4),
      i_char4 => "0" & switch_vol_w,
      i_char5 => x"0",
      i_char6 => x"0",
      i_char7 => x"0",
      o_AN    => AN,
      o_EN    => SEG7_CATH);                

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
      s_axis_phase_tdata => dds_in_w,
      m_axis_data_tvalid => open,
      m_axis_data_tdata => sin_w
    );
    
end architecture rtl;
