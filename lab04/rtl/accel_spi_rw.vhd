----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/07/2018 
-- Module Name:   accel_spi_rw
-- Project Name:  Lab04
--
-- Description:  acelleromteter read/write spi interface
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accel_spi_rw is
  Port(
    i_clk    : in    STD_LOGIC;
    i_mode   : in    STD_LOGIC; -- 1 for acelleromteter 0 for buttons
    i_rst    : in    STD_LOGIC;
    o_DATA_X :   out STD_LOGIC_VECTOR(7 downto 0); -- values read from acelleromteter
    o_DATA_Y :   out STD_LOGIC_VECTOR(7 downto 0);
    o_DATA_Z :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_AD  :   out STD_LOGIC_VECTOR(7 downto 0);
    o_ID_1D  :   out STD_LOGIC_VECTOR(7 downto 0);
    o_MOSI   :   out STD_LOGIC; -- SPI signals for accelleromteter
    o_CS     :   out STD_LOGIC;
    o_SCLK   :   out STD_LOGIC;
    i_MISO   : in    STD_LOGIC);
end entity accel_spi_rw;

architecture rtl of accel_spi_rw is

type top_state_type is (standby, new_command, load_out, shift_out, reg_data);
signal curr_state, next_state : top_state_type;

type cmd_state_type is (standby, meas_mode, id_ad, id_1d, xdata, ydata, zdata);
signal curr_cmd, next_cmd : cmd_state_type;

signal w_new_cmd, w_write, w_reg_data, d_SCLK, w_MOSI, w_vld_accel, q_reg_data, w_sipo_start: std_logic;
signal w_spi_rw_done, q_SCLK, w_sclk_det: std_logic;

signal w_piso_load : std_logic_vector(1 downto 0);

signal w_addr, w_data, w_cmd : std_logic_vector(7 downto 0);

signal w_message : std_logic_vector(23 downto 0);

signal  q_spi_cntr  : unsigned(4 downto 0);
constant k_w_max : unsigned(4 downto 0) := to_unsigned(23,5);
constant k_r1_max : unsigned(3 downto 0) := to_unsigned(15,4);
constant k_r2_max : unsigned(3 downto 0) := to_unsigned(10,4);

signal q_id_1d, q_id_ad, q_xdata, q_ydata, q_zdata, d_data_accel : std_logic_vector(7 downto 0);

signal w_cntr_clr, w_cntr_en : std_logic;


begin

 -- entity output signals
  o_DATA_X <= q_xdata;
  o_DATA_Y <= q_ydata;
  o_DATA_Z <= q_zdata;
  o_ID_AD  <= q_id_ad;
  o_ID_1D  <= q_id_1d;
  o_MOSI   <= w_MOSI;  
  o_CS     <= '0'; --'1' when (curr_state = standby) else '0';  
  o_SCLK   <= d_SCLK;
  
  
  C_spi_cntr : process(q_spi_cntr, w_sclk_det, curr_state, w_write)
  begin
    w_cntr_clr <= '0';
    w_cntr_en  <= '0';
    w_spi_rw_done <= '0';
    if (curr_state = shift_out) then

      if (w_sclk_det = '1') then
               
        if (w_write = '1') then
        
          if (q_spi_cntr < k_w_max) then
            w_cntr_en <= '1';
          else
            w_cntr_clr <= '1';
            w_spi_rw_done <= '1';
          end if;
          
        else 
        
          if (q_spi_cntr < k_r1_max) then
            w_cntr_en <= '1';
          else
            w_cntr_clr <= '1';
            w_spi_rw_done <= '1';
          end if;
        
        end if;
       
      end if;
      
    elsif (curr_state = reg_data) then
      if (w_sclk_det = '1') then
        if (q_spi_cntr < k_r2_max) then
          w_cntr_en <= '1';
        else
          w_cntr_clr <= '1';
          w_spi_rw_done <= '1';
        end if;    
      end if;
    else
      w_cntr_clr <= '1';
    end if;
  end process;

      
  -- SCLK rising edge detect
  w_sclk_det  <= d_SCLK AND NOT q_SCLK;    
  
  S_spi_cntr : process(i_clk, i_rst)
  begin  
    if (i_rst = '1') then
      q_spi_cntr   <= (others => '0');
      q_SCLK       <= '0';
      q_reg_data <= '0';
      
    elsif(rising_edge(i_clk)) then
      q_SCLK     <= d_SCLK;
      -- q_reg_data <= d_reg_data;
        if (w_cntr_clr = '1') then
          q_spi_cntr <= (others => '0');
        elsif (w_cntr_en = '1') then
          q_spi_cntr <= q_spi_cntr + 1;
        end if;
    end if;
  end process S_spi_cntr;
  
  -- S_spi_cntr : process(i_clk, i_rst)
  -- begin
    -- if (i_rst = '1') then
      -- q_spi_cntr <= (others => '0');
      -- -- w_spi_rw_done <= '0';
    -- elsif (rising_edge(i_clk)) then
      -- if (curr_state = shift_out) then
      
        -- if (w_sclk_det = '1') then
        
          -- if (q_spi_cntr = k_w_max) then
            -- q_spi_cntr <= (others => '0');
            -- -- w_spi_rw_done <= '1';
          -- else
            -- q_spi_cntr <= q_spi_cntr + 1;
            -- -- w_spi_rw_done <= '0';
          -- end if;
          
        -- end if
        
      -- elsif (curr_state = reg_data) then
        
        -- if (w_sclk_det = '1') then
      
          -- if (q_spi_cntr = k_r1_max) then
            -- q_spi_cntr <= (others => '0');
            -- -- w_spi_rw_done <= '1';
          -- else
            -- q_spi_cntr <= q_spi_cntr + 1;
            -- -- w_spi_rw_done <= '0';
          -- end if;      
        
        -- end if;
      -- end if
    -- end if;   
  -- end process p_spi_cntr;  
  
  ----------------------------- top level state machine---------------------------------------
  -- top state machine outputs
  w_new_cmd   <= '1'  when (curr_state = new_command) else '0';  
  
  with curr_state select
    w_piso_load <= "01" when load_out,
                   "10" when shift_out,
                   "00" when others;  
                
  w_reg_data   <= '1' when (curr_state = reg_data) else '0';
  -- w_sipo_start <= d_reg_data AND NOT q_reg_data;
 

  S_top_state_reg : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then 
      curr_state <= standby;
    elsif (rising_edge(i_clk)) then
      curr_state <= next_state;
    end if;
  end process S_top_state_reg;
  
  FSM_top_logic : process(curr_state, i_mode, w_write, w_spi_rw_done)
  begin 
    
    next_state <= curr_state;  --default to "stay at current state"
    case curr_state is 
      when standby =>
        if (i_mode = '1') then
          next_state <= new_command;
        end if;
        
      when new_command =>
        next_state <= load_out;
        
      when load_out =>
        next_state <= shift_out;
      
      when shift_out =>
        if (w_spi_rw_done = '1') then 
          if (w_write = '1') then
            next_state <= new_command;
          else
            next_state <= reg_data;
          end if;
        end if;
        
      when reg_data =>
        if (w_spi_rw_done = '1') then
          next_state <= new_command;
        end if;      
          
        when others => 
          next_state <= standby;
    end case;  
  end process FSM_top_logic;
  
  ----------------------------- command level state machine---------------------------------------  

  -- cmd state machine outputs
  w_message <= (w_cmd & w_addr & w_data) when (curr_cmd =  meas_mode) else (w_cmd & w_addr & x"00");  
  
  w_write <= '1'   when (curr_cmd =  meas_mode) else '0';
  w_cmd   <= x"0a" when (curr_cmd =  meas_mode OR curr_cmd = standby) else x"0b";  -- write = 0x0A, read = 0x0B
  w_data  <= x"02" when (curr_cmd = meas_mode OR curr_cmd = standby)  else x"00";
  with curr_cmd select
    w_addr <= 
      x"2D" when meas_mode, -- set to meas mode
      x"00" when id_ad ,
      x"01" when id_1d,
      x"08" when xdata,
      x"09" when ydata,
      x"0A" when zdata,
      x"00" when others;
      
  S_data_sel : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      q_id_1d <= (others => '0');
      q_id_ad <= (others => '0');
      q_xdata <= (others => '0');
      q_ydata <= (others => '0');
      q_zdata <= (others => '0');
    elsif(rising_edge(i_clk)) then
      if (w_vld_accel = '1') then
        case curr_cmd is
          when id_ad =>
            q_id_ad <= d_data_accel;
            
           when id_1d =>
             q_id_1d <= d_data_accel;
            
           when xdata =>
             q_xdata <= d_data_accel;
           
           when ydata =>
             q_ydata <= d_data_accel;
             
           when zdata =>
             q_zdata <= d_data_accel;
             
           when others => 
             null;  
        end case;
      end if;
    end if;
  end process S_data_sel;
      

  -- accel cmd state logic
  S_cmd_state_reg : process(i_clk, i_rst)
  begin
    if (i_rst = '1') then
      curr_cmd <= standby;
    elsif (rising_edge(i_clk)) then
      curr_cmd <= next_cmd;
    end if;
  end process S_cmd_state_reg;
  
  FSM_cmd_logic : process(curr_cmd, w_new_cmd)
  begin
    
    next_cmd <= curr_cmd;
    case curr_cmd is
      
      when standby =>
        if (i_mode = '1' AND w_new_cmd = '1') then
          next_cmd <= meas_mode;
        end if;
      when meas_mode => 
        if (w_new_cmd = '1') then
          next_cmd <= id_ad;
        end if;
      
      when id_ad =>
        if (w_new_cmd = '1') then
          next_cmd <= id_1d;
        end if;
        
      when id_1d =>
        if (w_new_cmd = '1') then 
          next_cmd <= xdata;
        end if;
        
      when xdata =>
        if (w_new_cmd = '1') then
          next_cmd <= ydata;
        end if;
        
      when ydata =>
        if (w_new_cmd = '1') then
          next_cmd <= zdata;
        end if;

      when zdata =>
        if (w_new_cmd = '1') then
          next_cmd <= xdata;
        end if;   
          
      when others => 
        next_cmd <= standby;
    end case;
  end process FSM_cmd_logic;
  ------------------------------------------------------------------------------------------------

  
  U_PISO : entity work.piso(rtl) 
    Generic map(
      g_width => 24)
    Port map(
      i_clk   => i_clk,
      i_en    => w_sclk_det,
      i_rst   => i_rst,
      i_din   => w_message,
      i_mode  => w_piso_load,
      o_sdout => w_MOSI);
      
  U_SIPO : entity work.sipo(rtl) 
    Generic map(
      g_reg_width  => 8,
      g_cntr_width => 4)
    Port map(
      i_clk      => i_clk,       
      i_rst      => i_rst,       
      i_en_1MHz  => w_sclk_det,      
      i_sin      => i_MISO,
      i_reg_data => w_reg_data,
      o_pout     => d_data_accel,
      o_vld      => w_vld_accel);

  U_1MHz_SCLK : entity work.clk_div(rtl) 
    Generic map(
      g_max_cnt   => 50,  -- count for half a period 
      g_max_width => 6)
    Port map(
      i_clk     => i_clk,
      i_reset   => i_rst,
      o_clk_div => d_SCLK);
        

end architecture rtl;