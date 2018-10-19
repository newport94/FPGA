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
 
  signal w_db_up, w_db_left, w_db_right, w_db_down : std_logic;
  signal w_rst, w_mode : std_logic;
  signal w_x_index, w_y_index : std_logic_vector(7 downto 0);
  signal w_pb_array, w_db_array : std_logic_vector(3 downto 0);
  signal w_data_ad, w_data_1d, w_data_x, w_data_y, w_data_z : std_logic_vector(7 downto 0);
  signal w_disp : std_logic_vector(1 downto 0);
  signal w_char4, w_char5, w_char6, w_char7  : std_logic_vector (3 downto 0);
  
  
  

begin
  w_rst       <= SW(0);
  w_pb_array  <= (BTNU, BTNL, BTNR, BTND);
  w_db_up     <= w_db_array(0);
  w_db_left   <= w_db_array(1);
  w_db_right  <= w_db_array(2);
  w_db_down   <= w_db_array(3);
  w_mode      <= SW(1);
  w_disp      <= SW(4 downto 3); -- controls digits 4 - 7
                                    -- '00' --> display 1D in digits 7-6 and AD in 5-4
                                    -- '01' --> display x data in digits 5-4, zeros in 7-6
                                    -- '10' --> display y data in digits 5-4, zeros in 7-6
                                    -- '11' --> dispaly z data in digits 5-4, zeros in 7-6
                                    
                                    
  -- select char signals with w_disp
  
  C_char_sel : process(w_mode, w_disp)
  begin
    if (w_mode = '1') then
      case w_disp is
        when "00" =>
          w_char4 <= w_data_ad(3 downto 0);
          w_char5 <= w_data_ad(7 downto 4);
          w_char6 <= w_data_id(3 downto 0);
          w_char7 <= w_data_id(7 downto 4);
        when "01" =>
          w_char4 <= w_data_x(3 downto 0);
          w_char5 <= w_data_x(7 downto 4);
          w_char6 <= x"0";
          w_char7 <= x"0";
        when "10" =>
          w_char4 <= w_data_y(3 downto 0);
          w_char5 <= w_data_y(7 downto 4);
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

  
  
  
  ACCEL_SPI : entity work.accel_spi_rw(rtl)
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
      i_db_up    => w_db_up,
      i_db_left  => w_db_left,
      i_db_right => w_db_right,
      i_db_down  => w_db_down,
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
        
        
  -- UP_BUTTON : entity work.debounce(rtl) 
    -- Port map(
      -- i_clk => CLK100MHZ,   -- 100 MHz clk
      -- i_rst => w_rst,
      -- i_pb  => BTNU,
      -- o_db  => w_db_up);
      
  -- LEFT_BUTTON : entity work.debounce(rtl) 
    -- Port map(
      -- i_clk => CLK100MHZ,   -- 100 MHz clk
      -- i_rst => w_rst,
      -- i_pb  => BTNL,
      -- o_db  => w_db_left);

  -- RIGHT_BUTTON : entity work.debounce(rtl) 
    -- Port map(
      -- i_clk => CLK100MHZ,   -- 100 MHz clk
      -- i_rst => w_rst,
      -- i_pb  => BTNR,
      -- o_db  => w_db_right);

  -- DOWN_BUTTON : entity work.debounce(rtl) 
    -- Port map(
      -- i_clk => CLK100MHZ,   -- 100 MHz clk
      -- i_rst => w_rst,
      -- i_pb  => BTND,
      -- o_db  => w_db_down);
    
 end architecture rtl;