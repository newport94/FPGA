----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   11/10/2018 
-- Module Name:   accel_spi_rw2
-- Project Name:  Lab04
--
-- Description:  acelleromteter read/write spi interface second attempt
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accel_spi_rw2 is
  Port(
    i_clk    : in    STD_LOGIC;
    i_mode   : in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
    i_rst    : in    STD_LOGIC;
    i_din    : in    STD_LOGIC_VECTOR(23 downto 0);
    o_dout   :   out STD_LOGIC_VECTOR(7 downto 0);
    o_done   :   out STD_LOGIC;
    o_MOSI   :   out STD_LOGIC; -- SPI signals for accelleromteter
    o_CS     :   out STD_LOGIC;
    o_SCLK   :   out STD_LOGIC;
    i_MISO   : in    STD_LOGIC);
end entity accel_spi_rw2;

architecture rtl of accel_spi_rw2 is

constant k_max_cnt : unsigned(4 downto 0) := to_unsigned(24,5);

type spi_states is (IDLE, PREPARE, SHIFT, DONE);
signal curr_state, next_state : spi_states;

signal w_start_shift, w_shift_done, w_sclk_red, w_sclk_fed, w_cntr_en : std_logic;
signal d_SCLK, q_SCLK, q_MOSI : std_logic; --, w_cs_toggle, q_cs : std_logic;
signal q_bit_cntr : unsigned(4 downto 0);
signal q_MOSI_shift : std_logic_vector(23 downto 0);
signal q_MISO, q_dout : std_logic_vector(7 downto 0);

begin
  -- assign outputs
  o_SCLK <= d_SCLK;
  o_CS   <= '0' when (curr_state = SHIFT) else '1';
  o_MOSI <= q_MOSI;
  o_dout <= q_dout;
  o_done <= '1' when curr_state = DONE;
  
  -- SCLK edge detects
  w_sclk_red <= d_SCLK AND NOT q_SCLK; 
  w_sclk_fed <= q_SCLK AND NOT d_SCLK;  
  
  -- output register 
  P_DOUT : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_dout <= (others => '0');
    elsif (rising_edge(i_clk)) then 
      if ((curr_state = SHIFT) OR (curr_state = DONE)) then 
        q_dout <= q_MISO;
      end if;
    end if;
  end process P_DOUT;
    

  -- shift registers
  
  P_SHIFT_OUT : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_MOSI_shift <= (others => '0');    
      q_MOSI <= '0';
    elsif(rising_edge(i_clk)) then 
      if ((curr_state = SHIFT OR curr_state = PREPARE) AND w_sclk_fed = '1') then
        q_MOSI_shift <= q_MOSI_shift(22 downto 0) & '0';
        q_MOSI <= q_MOSI_shift(23);      
      elsif (curr_state = PREPARE) then 
        q_MOSI_shift <= i_din;         
      end if;    
    end if;
  end process P_SHIFT_OUT;
  
  P_SHIFT_IN : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      q_MISO <= (others => '0'); 
    elsif (rising_edge(i_clk)) then 
      if (w_sclk_fed = '1') then 
        if (curr_state = SHIFT) then 
          q_MISO <= q_MISO(6 downto 0) & i_MISO;
        end if;
      end if;
    end if;
  end process P_SHIFT_IN;
  
  
  -- bit counter
  w_cntr_en  <=  '1' when (curr_state = SHIFT) else '0';
  -- w_cs_toggle <= '1' when (q_bit_cntr = 0 OR q_bit_cntr = (k_max_cnt - 1)) AND w_cntr_en = '1' else '0';
  
  P_BIT_CNTR : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      q_bit_cntr <= (others => '0');
      q_sclk <= '0';  
      -- q_cs <= '1';
    elsif (rising_edge(i_clk)) then 
      q_sclk <= d_SCLK;
      if (w_shift_done = '1') then  
        q_bit_cntr <= (others => '0');
      elsif (w_cntr_en = '1' AND w_sclk_fed = '1') then         
        q_bit_cntr <= q_bit_cntr + 1;
          -- if (w_cs_toggle = '1')  then 
            -- q_cs <= not q_cs;
          -- end if;
      end if;
    end if;
  end process P_BIT_CNTR;
  
  -- state machine control signals
  w_start_shift <= '1' when (curr_state = PREPARE) AND (w_sclk_fed = '1') else '0';
  w_shift_done  <= '1' when (curr_state = SHIFT) AND (q_bit_cntr = k_max_cnt) else '0';  

  -- SPI controller state machine
  P_FSM_REG: process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      curr_state <= IDLE;
    elsif (rising_edge(i_clk)) then
      curr_state <= next_state;
    end if;  
  end process P_FSM_REG;
  
  P_FSM_LOGIC : process(curr_state, i_mode, w_start_shift, w_shift_done, w_sclk_fed, w_sclk_red)
  begin
    next_state <= curr_state;
    case curr_state is 
      when IDLE =>
        if (i_mode = '1' AND w_sclk_red = '1') then 
          next_state <= PREPARE;
        end if;
      
      when PREPARE =>
        if (w_start_shift = '1') then 
          next_state <= SHIFT;
        end if;
        
      when SHIFT =>
        if (w_shift_done = '1') then
          next_state <= DONE;
        end if;
      
      when DONE =>
        next_state <= IDLE;
        
      when others =>
        next_state <= IDLE;
    end case;
  end process P_FSM_LOGIC;



  U_1MHz_SCLK : entity work.clk_div(rtl) 
    Generic map(
      g_max_cnt   => 50,  -- count for half a period 
      g_max_width => 6)
    Port map(
      i_clk     => i_clk,
      i_reset   => i_rst,
      o_clk_div => d_SCLK);
        

end architecture rtl;