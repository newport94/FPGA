----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   11/17/2018 
-- Module Name:   accel_spi_cntrl
-- Project Name:  Lab04
--
-- Description:  acelleromteter read/write spi interface second attempt
--               higher level entity which is responsible for choosing 
--               read/write bytes, addresses, and such with a FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accel_spi_cntrl is
  Port(
    i_clk    : in    STD_LOGIC;
    i_mode   : in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
    i_rst    : in    STD_LOGIC;
    o_DATA_X :   out STD_LOGIC_VECTOR(7 downto 0);
    o_DATA_Y :   out STD_LOGIC_VECTOR(7 downto 0);
    o_DATA_Z :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_AD  :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_1D  :   out STD_LOGIC_VECTOR(7 downto 0);
    -- SPI SIGNALS
    o_MOSI   :   out STD_LOGIC; -- SPI signals for accelleromteter
    o_CS     :   out STD_LOGIC;
    o_SCLK   :   out STD_LOGIC;
    i_MISO   : in    STD_LOGIC);
end entity accel_spi_cntrl;

architecture rtl of accel_spi_cntrl is

  component accel_spi_rw2 is
    Port(
      i_clk    : in    STD_LOGIC;
      i_mode   : in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
      i_rst    : in    STD_LOGIC;
      i_din    : in    STD_LOGIC_VECTOR(23 downto 0);
      o_dout   :   out STD_LOGIC_VECTOR(7 downto 0);
      o_shift  :   out STD_LOGIC;
      o_rd_vld :   out STD_LOGIC;
      o_done   :   out STD_LOGIC;
      -- SPI SIGNALS
      o_MOSI   :   out STD_LOGIC; -- SPI signals for accelleromteter
      o_CS     :   out STD_LOGIC;
      o_SCLK   :   out STD_LOGIC;
      i_MISO   : in    STD_LOGIC);
  end component;
  
  -- message constants
  constant k_w_cmd    : std_logic_vector(7 downto 0) := x"0A";
  constant k_r_cmd    : std_logic_vector(7 downto 0) := x"0B";
  constant k_AD_addr  : std_logic_vector(7 downto 0) := x"00";
  constant k_ID_addr  : std_logic_vector(7 downto 0) := x"01";
  constant k_X_addr   : std_logic_vector(7 downto 0) := x"08";
  constant k_Y_addr   : std_logic_vector(7 downto 0) := x"09";
  constant k_Z_addr   : std_logic_vector(7 downto 0) := x"0A";
  constant k_pow_addr : std_logic_vector(7 downto 0) := x"2D";
  constant k_measure  : std_logic_vector(7 downto 0) := x"02";
  constant k_standby  : std_logic_vector(7 downto 0) := x"00";
  
  -- message signals
  constant k_msg_cnt_max : unsigned(2 downto 0) := to_unsigned(5,3);
  signal w_cmd, w_addr, w_payload : std_logic_vector(7 downto 0);
  signal d_message, q_message : std_logic_vector(23 downto 0);
  
  -- read spi signals
  signal d_accel_reg, q_DATA_X, q_DATA_Y, q_DATA_Z, q_ID_AD, q_ID_1D : std_logic_vector(7 downto 0);
  
  -- FSM states
  type msg_states is (IDLE, LOAD_MSG, HOLD, READ_MSG);
  signal curr_state, next_state : msg_states;

  -- FSM control signals
  signal d_done, q_done, w_read_vld, w_shift, w_done_det : std_logic;
  signal w_cntr_rst : std_logic;
  signal q_cntr : unsigned(2 downto 0);


begin
  o_DATA_X <= q_DATA_X;
  o_DATA_Y <= q_DATA_Y;
  o_DATA_Z <= q_DATA_Z;
  o_ID_AD  <= q_ID_AD; 
  o_ID_1D  <= q_ID_1D; 
  
  -- read accel register from SPI
  p_read_spi : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_ID_AD  <= (others => '0');
      q_ID_1D  <= (others => '0');
      q_DATA_X <= (others => '0');
      q_DATA_Y <= (others => '0');
      q_DATA_Z <= (others => '0');
    elsif (rising_edge(i_clk)) then 
      if (curr_state = READ_MSG) then 
        if (q_cntr = 1) then 
          q_ID_AD <= d_accel_reg;
          
        elsif (q_cntr = 2) then 
          q_ID_1D <= d_accel_reg;
          
        elsif (q_cntr = 3) then 
          q_DATA_X <= d_accel_reg;
          
        elsif (q_cntr = 4) then 
          q_DATA_Y <= d_accel_reg;
          
        elsif (q_cntr = 5) then 
          q_DATA_Z <= d_accel_reg;  
        end if;
      end if;
    end if;
  end process p_read_spi;
  
  -- command select
  w_cmd <= k_w_cmd when (q_cntr = 0) else k_r_cmd;
  
  -- address select
  with q_cntr select
    w_addr <= 
      k_pow_addr when "000", --to_unsigned(0,3),
      k_AD_addr  when "001", --to_unsigned(1,3),
      k_ID_addr  when "010", --to_unsigned(2,3),
      k_X_addr   when "011", --to_unsigned(3,3),
      k_Y_addr   when "100", --to_unsigned(4,3),
      k_Z_addr   when "101", --to_unsigned(5,3),
      k_AD_addr  when others;
      
  -- payload select
  w_payload <= k_measure when (q_cntr = 0) else k_standby;
  
  -- form message
  d_message <= w_cmd & w_addr & w_payload;
  
  -- load message process
  p_load_msg : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_message <= (others => '0');
    elsif (rising_edge(i_clk)) then 
      if (curr_state = LOAD_MSG) then 
        q_message <= d_message;
      end if;
    end if;      
  end process p_load_msg;
  

  -- message counter control signals
  w_cntr_rst <= '1' when (q_cntr = k_msg_cnt_max) else '0';
  w_done_det <= d_done AND NOT q_done;
  
  -- message counter
  p_cntr : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_cntr <= (others => '0');
      q_done <= '0';
    elsif (rising_edge(i_clk)) then
      q_done <= d_done;
      if (w_cntr_rst = '1') then 
        q_cntr <= "001";
      elsif (w_done_det = '1') then 
        q_cntr <= q_cntr + 1;
      end if;
    end if;            
  end process p_cntr;


  p_fsm_reg : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      curr_state <= IDLE;
    elsif (rising_edge(i_clk)) then
      curr_state <= next_state;
    end if; 
  end process p_fsm_reg;
  
  p_fsm_logic : process(curr_state, d_done, w_read_vld, w_shift)
  begin
    next_state <= curr_state;
    case curr_state is
      when IDLE =>
        if (i_mode = '1') then 
          next_state <= LOAD_MSG;
        end if;
        
      when LOAD_MSG =>
        if (w_shift = '1') then 
          next_state <= HOLD;
        end if;
        
      when HOLD =>
        if (w_read_vld = '1') then 
          next_state <= READ_MSG;
        end if;
        
      when READ_MSG =>
        if (d_done <= '1') then 
          next_state <= LOAD_MSG;
        end if;
        
      when others =>
        next_state <= IDLE;
    end case;
  end process p_fsm_logic;


  U_SPI_RW : accel_spi_rw2
    Port Map(
      i_clk    => i_clk ,      --: in    STD_LOGIC;
      i_mode   => i_mode,      --: in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
      i_rst    => i_rst ,      --: in    STD_LOGIC;
      i_din    => q_message,   --: in    STD_LOGIC_VECTOR(23 downto 0);
      o_dout   => d_accel_reg, --:   out STD_LOGIC_VECTOR(7 downto 0);
      o_shift  => w_shift,     --:   out STD_LOGIC;
      o_rd_vld => w_read_vld,  --:   out STD_LOGIC;
      o_done   => d_done,      --:   out STD_LOGIC;
      o_MOSI   => o_MOSI,      --:   out STD_LOGIC; -- SPI signals for accelleromteter
      o_CS     => o_CS  ,      --:   out STD_LOGIC;
      o_SCLK   => o_SCLK,      --:   out STD_LOGIC;
      i_MISO   => i_MISO);     --: in    STD_LOGIC);




end architecture rtl;