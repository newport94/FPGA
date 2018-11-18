----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   10/07/2018 
-- Module Name:   lab04_top
-- Project Name:  Lab04
--
-- Description:  top level entity  for lab 04
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity lab04_top is
  Port(
    CLK100MHZ : in    STD_LOGIC;                       -- clock
    SW        : in    STD_LOGIC_VECTOR(5 downto 0);    -- Switches[4:0]
    BTNU      : in    STD_LOGIC;                       -- push buttons
    BTNL      : in    STD_LOGIC;
    BTNR      : in    STD_LOGIC;
    BTND      : in    STD_LOGIC;
    VGA_R     :   out STD_LOGIC_VECTOR(3 downto 0);    -- vga controller
    VGA_G     :   out STD_LOGIC_VECTOR(3 downto 0);
    VGA_B     :   out STD_LOGIC_VECTOR(3 downto 0);
    VGA_HS    :   out STD_LOGIC;
    VGA_VS    :   out STD_LOGIC;
    SEG7_CATH :   out STD_LOGIC_VECTOR(7 downto 0);   -- seven segment controller
    AN        :   out STD_LOGIC_VECTOR(7 downto 0);    
    ACL_MISO  : in    STD_LOGIC;                      -- acellerometer SPI
    ACL_MOSI  :   out STD_LOGIC;
    ACL_SCLK  :   out STD_LOGIC;                          -- 100 MHz Sclk
    ACL_CSN   :   out STD_LOGIC);
end entity lab04_top;
 
architecture rtl of lab04_top is

  constant k_pos_thr_low  : unsigned(7 downto 0) := x"3A";
  constant k_pos_thr_high : unsigned(7 downto 0) := x"60";  
  constant k_neg_thr_low  : unsigned(7 downto 0) := x"C0";
  constant k_neg_thr_high : unsigned(7 downto 0) := x"A0";


 
  signal w_db_up, w_db_left, w_db_right, w_db_down : std_logic;
  signal w_rst, w_mode : std_logic;
  signal w_x_index, w_y_index : std_logic_vector(7 downto 0);
  signal w_pb_array, w_db_array : std_logic_vector(3 downto 0);
  signal w_data_ad, w_data_1d, w_data_x, w_data_y, w_data_z : std_logic_vector(7 downto 0);
  signal w_disp : std_logic_vector(1 downto 0);
  signal w_char4, w_char5, w_char6, w_char7  : std_logic_vector (3 downto 0);
  signal w_mv_up, w_mv_left, w_mv_right, w_mv_down : std_logic;
  
  signal q_accel_left, q_accel_right, q_accel_up, q_accel_down : std_logic;
  signal d_accel_left, d_accel_right, d_accel_up, d_accel_down : std_logic;  
  signal w_accel_left, w_accel_right, w_accel_up, w_accel_down : std_logic;    
  
  

begin
  w_rst       <= SW(0);
  w_pb_array  <= (BTNU, BTNL, BTNR, BTND);
  w_db_up     <= w_db_array(0);
  w_db_left   <= w_db_array(1);
  w_db_right  <= w_db_array(2);
  w_db_down   <= w_db_array(3);
  w_mode      <= SW(1);
  w_disp      <= SW(4 downto 3); -- controls digits 7 - 4
                                    -- '00' --> display 1D in digits 7-6 and AD in 5-4
                                    -- '01' --> display x data in digits 5-4, zeros in 7-6
                                    -- '10' --> display y data in digits 5-4, zeros in 7-6
                                    -- '11' --> dispaly z data in digits 5-4, zeros in 7-6
                                    
  w_mv_left  <= w_accel_left  when (w_mode = '1') else w_db_up   ;
  w_mv_right <= w_accel_right when (w_mode = '1') else w_db_left ;                              
  w_mv_up    <= w_accel_up    when (w_mode = '1') else w_db_right;                             
  w_mv_down  <= w_accel_down  when (w_mode = '1') else w_db_down ;
                                
  -- set accel thresholds for moving red square
  -- positive threshold =  > 0x03
  -- negative threshold =  < 0x0D
  d_accel_left  <= '1' when ((unsigned(w_data_y) > k_pos_thr_low) AND (unsigned(w_data_y) < k_pos_thr_high)) else '0';
  d_accel_right <= '1' when ((unsigned(w_data_y) < k_neg_thr_low) AND (unsigned(w_data_y) > k_neg_thr_high)) else '0';
  d_accel_up    <= '1' when ((unsigned(w_data_x) < k_neg_thr_low) AND (unsigned(w_data_x) > k_neg_thr_high)) else '0';
  d_accel_down  <= '1' when ((unsigned(w_data_x) > k_pos_thr_low) AND (unsigned(w_data_x) < k_pos_thr_high)) else '0';
  
  w_accel_left  <= d_accel_left  AND NOT q_accel_left;
  w_accel_right <= d_accel_right AND NOT q_accel_right;
  w_accel_up    <= d_accel_up    AND NOT q_accel_up;
  w_accel_down  <= d_accel_down  AND NOT q_accel_down;
  
  S_accel_thresh : process(CLK100MHZ, w_rst)
  begin
    if (w_rst = '1') then 
      q_accel_left  <= '0';
      q_accel_right <= '0';
      q_accel_up    <= '0';
      q_accel_down  <= '0';
    elsif (rising_edge(CLK100MHZ)) then 
      q_accel_left  <= d_accel_left ;
      q_accel_right <= d_accel_right;
      q_accel_up    <= d_accel_up   ;
      q_accel_down  <= d_accel_down ;    
    end if;
  end process S_accel_thresh;
                                    
                                    
  -- select char signals with w_disp
  C_char_sel : process(w_mode, w_disp, w_data_ad, w_data_1d, w_data_x, w_data_y, w_data_z)
  begin
    if (w_mode = '1') then
      case w_disp is
        when "00" =>
          w_char4 <= w_data_ad(3 downto 0);
          w_char5 <= w_data_ad(7 downto 4);
          w_char6 <= w_data_1d(3 downto 0);
          w_char7 <= w_data_1d(7 downto 4);
        when "01" =>
          w_char4 <= w_data_y(3 downto 0);--w_data_x(3 downto 0);   -- x and y appear to be opposite of expected relative to 7 segment display
          w_char5 <= w_data_y(7 downto 4);--w_data_x(7 downto 4);   -- so I switched them 
          w_char6 <= x"0";
          w_char7 <= x"0";
        when "10" =>
          w_char4 <= w_data_x(3 downto 0);--w_data_y(3 downto 0);
          w_char5 <= w_data_x(7 downto 4);--w_data_y(7 downto 4);
          w_char6 <= x"0";
          w_char7 <= x"0";
        when "11" =>
          w_char4 <= w_data_z(3 downto 0);
          w_char5 <= w_data_z(7 downto 4);
          w_char6 <= x"0";
          w_char7 <= x"0";  
        when others =>
          w_char4 <= x"0";
          w_char5 <= x"0";
          w_char6 <= x"0";
          w_char7 <= x"0"; 
      end case;              
    else
      w_char4 <= x"0";
      w_char5 <= x"0";
      w_char6 <= x"0";
      w_char7 <= x"0";    
    end if;
  
  end process C_char_sel;


  ACCEL_SPI : entity work.accel_spi_cntrl(rtl)
    Port map(
      i_clk    => CLK100MHZ,
      i_mode   => w_mode,
      i_rst    => w_rst,
      o_DATA_X => w_data_x,
      o_DATA_Y => w_data_y,
      o_DATA_Z => w_data_z,
      o_ID_AD  => w_data_ad,
      o_ID_1D  => w_data_1d,
      o_MOSI   => ACL_MOSI,
      o_CS     => ACL_CSN,
      o_SCLK   => ACL_SCLK,
      i_MISO   => ACL_MISO);

  VGA : entity work.vga_controller(rtl)
    Port map(
      i_clk      => CLK100MHZ,
      i_rst      => w_rst,
      i_db_up    => w_mv_up,
      i_db_left  => w_mv_left,
      i_db_right => w_mv_right,   
      i_db_down  => w_mv_down, 
      o_vga_red  => VGA_R, 
      o_vga_grn  => VGA_G,
      o_vga_blu  => VGA_B,
      o_h_sync   => VGA_HS,
      o_v_sync   => VGA_VS,
      o_y_index  => w_y_index,
      o_x_index  => w_x_index);   
      
  SEG7:  entity work.seg7_controller(rtl)
    Port map(
      i_clk   => CLK100MHZ,
      i_rst   => w_rst,
      i_char0 => w_y_index(3 downto 0),
      i_char1 => w_y_index(7 downto 4),
      i_char2 => w_x_index(3 downto 0),
      i_char3 => w_x_index(7 downto 4),
      i_char4 => w_char4,
      i_char5 => w_char5,
      i_char6 => w_char6,
      i_char7 => w_char7,
      o_AN    => AN,
      o_EN    => SEG7_CATH);

      
  GEN_PUSH_BUTTONS : for ii in 0 to 3 generate
    recognizers : entity work.debounce(rtl)
      Port map(
      i_clk => CLK100MHZ,   
      i_rst => w_rst,        
      i_pb  => w_pb_array(ii),        
      o_db  => w_db_array(ii));
  end generate GEN_PUSH_BUTTONS;
        
 end architecture rtl;