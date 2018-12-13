----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   12/09/2018 
-- Module Name:   tb_top_level
-- Project Name:  Lab03
--
-- Description:  testbench for microphone interface
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.all;

-- empty tb_top_level entity
entity tb_top_level is
end entity tb_top_level;

architecture tb of tb_top_level is 


component final_proj_top is
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(15 downto 0);    
    BTNR      : in    STD_LOGIC;   
    BTNL      : in    STD_LOGIC;
    -- seven seg display
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0);
    -- microphone
    M_CLK     :   out STD_LOGIC; 
    M_DATA    : in    STD_LOGIC;
    M_LRSEL   :   out STD_LOGIC;
    -- Audio jack signals
    AUD_PWM   :   out STD_LOGIC;                      -- audio pwm output
    AUD_SD    :   out STD_LOGIC;
    LED       :   out STD_LOGIC_VECTOR(15 downto 0));-- audio output enable
end component;


signal clk   : STD_LOGIC;
signal rst   : STD_LOGIC;

signal mic_clk, mic_sel, pdm_vld, mdata : std_logic;
signal pdm_data : std_logic_vector(15 downto 0);
signal aud_out, aud_en_in, aud_en_out : std_logic;
signal switches, leds : std_logic_vector(15 downto 0);
signal volume : std_logic_vector(2 downto 0);
signal BTNL, BTNR : std_logic;

begin


  rst     <= '0', '1' after 20 ns, '0' after 100 ns;
  
  volume <= "011";
  aud_en_in <= '1';
  
  switches <= aud_en_in & '0' & "00000000" & volume & "00" & rst;
  

  
  process -- no sensitivity list
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;        -- 100 MHz clock (10 ns period)  

  process
  begin
    mdata <= '0';
    wait for 2.84 us;
    mdata <= '1';
    wait for 0.5 us;
    mdata <= '0';
    wait for 2 us;
    mdata <= '1';
    wait for 1.5 us;
    mdata <= '0';
    wait for 3 us;
    mdata <= '1';
    wait for 1 us;
  end process;
  
  process
  begin
    BTNL <= '0';
    wait for 5.3 us;
    BTNL <= '1';
    wait for 2 us;
    BTNL <= '0';
    -- wait for 50 us;
    -- BTNR <= '1';
    -- wait for 2 us;
    -- BTNR <= '0'; 
    wait;
  end process;
    


  UUT : final_proj_top
    Port Map(
      CLK100MHZ => clk,
      SW        => switches,
      BTNL      => BTNL,
      BTNR      => BTNR,
      SEG7_CATH => open,
      AN        => open,
      M_CLK     => mic_clk,
      M_DATA    => mdata,
      M_LRSEL   => mic_sel,
      AUD_PWM   => aud_out,
      AUD_SD    => aud_en_out,
      LED       => leds);


      
  
end architecture tb;