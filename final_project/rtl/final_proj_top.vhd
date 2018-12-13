----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/28/2018 
-- Module Name:   final_proj_top
-- Project Name:  Final Project
--
-- Description:  top level entity  for microphone playback final project

-- BTNC = system reset
-- BUTR = Record enable
--
--  SW [15] = audio output enable
--  SW[14] = record enable
--  SW [5..3] = volume, 
--  SW [2..0] = frequency, 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity final_proj_top is
  Port(
    CLK100MHZ : in    STD_LOGIC;
    SW        : in    STD_LOGIC_VECTOR(15 downto 0);    -- 
    --BTNU      : in    STD_LOGIC; 
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
    -- LEDS
    LED       :   out STD_LOGIC_VECTOR(15 DOWNTO 0));                     -- audio output enable
end entity final_proj_top;


architecture rtl of final_proj_top is

  COMPONENT fifo_generator_0
    PORT (
      clk          : IN    STD_LOGIC;
      srst         : IN    STD_LOGIC;
      din          : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
      wr_en        : IN    STD_LOGIC;
      rd_en        : IN    STD_LOGIC;
      dout         :   OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      full         :   OUT STD_LOGIC;
      almost_full  :   OUT STD_LOGIC;
      empty        :   OUT STD_LOGIC;
      almost_empty :   OUT STD_LOGIC;
      valid        :   OUT STD_LOGIC;
      data_count   :   OUT STD_LOGIC_VECTOR(16 DOWNTO 0));
   END COMPONENT;

  -- constants
  constant WORD_WIDTH_C : integer := 16;

  -- registers
  signal srst_q, srst_qq, rec_q, play_q : std_logic;
  
  -- wires
  signal word_vld_w, rec_strobe_w, play_strobe_w : std_logic;
  signal fifo_full_w, fifo_empty_w, fifo_wr_en_w, fifo_rd_en_w, audio_vld_w: std_logic;
  signal aud_rd_req_w, rst_w: std_logic;
  signal play_speed_w : std_logic_vector(1 downto 0);
  signal switch_vol_w : std_logic_vector(2 downto 0);
  signal pb_array_w, db_array_w : std_logic_vector(1 downto 0);
  signal mic_word_w, audio_word_w : std_logic_vector(WORD_WIDTH_C-1 downto 0);
  signal fifo_count_w : std_logic_vector(16 DOWNTO 0);


begin

  -- push buttons
  pb_array_w  <= (BTNR, BTNL);
  rec_strobe_w   <= db_array_w(0); -- debounced left push button
  play_strobe_w  <= db_array_w(1); -- debounced right push button
  
  -- LEDs
  LED(0) <= fifo_wr_en_w;  -- recording
  LED(1) <= fifo_full_w;   -- recording done
  LED(2) <= fifo_rd_en_w;  -- playback
  LED(3) <= fifo_empty_w;  -- playback done

  -- switches
  AUD_SD       <= SW(15);  
  play_speed_w <= SW(3 downto 2);
  rst_w        <= SW(0);  
  
  -- synch rst for FIFO
  -- double registered to avoid metastability issues
  p_sync_rst : process(CLK100MHZ)
  begin
    if (rising_edge(CLK100MHZ)) then 
      srst_q  <= rst_w;
      srst_qq <= srst_q;
    end if;            
  end process p_sync_rst;
    
  -- playback and record registers
  p_control : process(CLK100MHZ, rst_w)
  begin
    if (rst_w = '1') then 
      rec_q  <= '0';
      play_q <= '0';
    elsif (rising_edge(CLK100MHZ)) then 
      -- record state
      if (rec_strobe_w = '1') then 
        rec_q <= '1';
      elsif (fifo_full_w = '1') then 
        rec_q <= '0';
      end if;
      -- play state
      if (play_strobe_w = '1') then 
        play_q <= '1';
      elsif (fifo_empty_w = '1') then
        play_q <= '0';
      end if;
    end if;
  end process p_control;
    
    
  fifo_wr_en_w <= '1' when  (rec_q  = '1') AND (word_vld_w = '1')  else '0';
  fifo_rd_en_w <= '1' when (play_q = '1') AND (aud_rd_req_w = '1') else '0';
   


  U_MIC_IF : entity work.mic_if(rtl)
  Generic Map(
    sr_width_g    => WORD_WIDTH_C,  
    cntr_width_g  => 5)  
  Port Map(  
    clk_100_i => CLK100MHZ,
    rst_i     => rst_w,
    -- mic if    
    m_data_i  => M_DATA,
    m_clk_o   => M_CLK,
    m_sel_o   => M_LRSEL,
    -- record   
    rec_strobe_w_i  => rec_strobe_w,
    -- data out  
    sr_data_o => mic_word_w,
    sr_vld_o  => word_vld_w);
    
   
  U_FIFO : fifo_generator_0
    PORT MAP (
      clk          => CLK100MHZ,
      srst         => srst_qq,
      din          => mic_word_w,
      wr_en        => fifo_wr_en_w, -- need:  data valid AND record enable
      rd_en        => fifo_rd_en_w, -- need:  generate read enable during playback mode
      dout         => audio_word_w,
      full         => fifo_full_w,  -- will become control signal to stop recording 
      almost_full  => open,
      empty        => fifo_empty_w, -- will become control signal to stop playback
      almost_empty => open,
      valid        => audio_vld_w,
      data_count   => fifo_count_w);    
    

  U_AUD_IF : entity work.audio_if(rtl)
  Port map(
    clk_100_i    => CLK100MHZ,   
    rst_i        => rst_w,        
    data_i       => audio_word_w,
    data_vld_i   => audio_vld_w,
    rd_req_o     => aud_rd_req_w, 
    sw_vol_i     => switch_vol_w,
    aud_pwm_o    => AUD_PWM,
    play_speed_i => play_speed_w);    
    
    
    
  SEG7:  entity work.seg7_controller(rtl)
    Port map(
      i_clk   => CLK100MHZ,
      i_rst   => rst_w,
      i_char0 => fifo_count_w(3 downto 0),
      i_char1 => fifo_count_w(7 downto 4),
      i_char2 => fifo_count_w(11 downto 8),
      i_char3 => fifo_count_w(15 downto 12),
      i_char4 => fifo_count_w(16 downto 13),
      i_char5 => x"0",
      i_char6 => x"0",
      i_char7 => x"0",
      o_AN    => AN,
      o_EN    => SEG7_CATH);    
    
  
      
  GEN_PUSH_BUTTONS : for ii in 0 to 1 generate
    recognizers : entity work.debounce(rtl)
      Port map(
      i_clk => CLK100MHZ,   
      i_rst => rst_w,        
      i_pb  => pb_array_w(ii),        
      o_db  => db_array_w(ii));
  end generate GEN_PUSH_BUTTONS;
  

  -- U_CIC_FIR : entity work.pdm_filter(rtl) 
  -- Port Map(
    -- clk_100_i    => CLK100MHZ,    --: in    STD_LOGIC;
    -- rst_i        => BTNC,         --: in    STD_LOGIC;
    -- pdm_word_i   => mic_word_w,   --: in    STD_LOGIC_VECTOR(15 downto 0);
    -- word_vld_i   => word_vld_w,   --: in    STD_LOGIC;
    -- fir_data_o   => data_filt_d,  --:   out STD_LOGIC(15 downto 0);
    -- fir_vld_o    => filt_vld_d,   --:   out STD_LOGIC;
    -- rdy_to_fir_i => '1' );         --: in    STD_LOGIC;
    
    
  -- p_reg_filt : process(CLK100MHZ, BTNC)
  -- begin
    -- if (BTNC = '1') then 
      -- data_aud_q <= (others => '0');
    -- elsif (rising_edge(CLK100MHZ)) then 
      -- filt_vld_q <= filt_vld_d;
      -- if (filt_vld_d = '1') then 
        -- data_aud_q <= data_filt_d;

      -- end if;
    -- end if;  
  -- end process p_reg_filt;
  
end architecture rtl;