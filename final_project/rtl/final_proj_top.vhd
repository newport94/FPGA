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
    BTNC      : in    STD_LOGIC;     
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
    AUD_SD    :   out STD_LOGIC);                     -- audio output enable
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
      almost_empty :   OUT STD_LOGIC
    );

  -- constants
  constant WORD_WIDTH_C : integer := 16;

  -- registers
  signal srst_q, srst_qq : std_logic;
  signal data_aud_q : std_logic_vector(WORD_WIDTH_C-1 downto 0);
  
  -- wires
  signal rec_en_w, word_vld_w, filt_vld_d, filt_vld_q, db_left_w, db_right_w  : std_logic;
  signal switch_vol_w : std_logic_vector(2 downto 0);
  signal pb_array_w, db_array_w : std_logic_vector(2 downto 0);
  signal pdm_word_w, data_filt_d : std_logic_vector(WORD_WIDTH_C-1 downto 0);


begin

  -- push buttons
  pb_array_w  <= (BTNL, BTNR);

  db_left_w   <= db_array_w(0);
  db_right_w  <= db_array_w(1);

  -- switches
  AUD_SD       <= SW(15);  
  rec_en_w     <= SW(14);
  switch_vol_w <= SW(5 downto 3);
  rst_w        <= SW(0);  
  
  -- synch rst for FIFO
  -- double registered to avoid metastability issues
    p_sync_rst : process(CLK100MHZ)
    begin
      if (rising_edge(CLK100MHZ)) then 
        srst_q  <= rst_w
        srst_qq <= srst_q;
      end if;            
    end process p_sync_rst;
    
    



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
    rec_en_i  => rec_en_w,
    -- data out  
    sr_data_o => pdm_word_w,
    sr_vld_o  => word_vld_w);
    
  U_FIFO : fifo_generator_0
    PORT MAP (
      clk          => CLK100MHZ,
      srst         => srst_qq,
      din          => din,
      wr_en        => wr_en, -- need:  data valid AND record enable
      rd_en        => rd_en, -- need:  generate read enable during playback mode
      dout         => dout,
      full         => full,  -- will become control signal to stop recording 
      almost_full  => open,
      empty        => empty, -- will become control signal to stop playback
      almost_empty => open);    
    
    
    
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
    -- pdm_word_i   => pdm_word_w,   --: in    STD_LOGIC_VECTOR(15 downto 0);
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

  U_AUD_PWM : entity work.audio_if(rtl)
  Port map(
    clk_100_i   => CLK100MHZ,       --: in    STD_LOGIC;
    rst_i       => BTNC,             --: in    STD_LOGIC;  
    data_i      => pdm_word_w, --data_aud_q,      --: in    STD_LOGIC_VECTOR(15 downto 0);
    vld_i       => word_vld_w, --filt_vld_q,      --: in    STD_LOGIC;
    sw_vol_i    => switch_vol_w,    --: in    STD_LOGIC_VECTOR(2 downto 0);
    aud_pwm_o   => AUD_PWM);        --:   out STD_LOGIC);
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    
    
    
    
    
    




end architecture rtl;