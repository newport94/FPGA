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
  signal w_rst : std_logic;
  signal w_x_index, w_y_index : std_logic_vector(7 downto 0);

begin

  w_rst <= SW(0);

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
      i_char4 => x"0",
      i_char5 => x"0",
      i_char6 => x"0",
      i_char7 => x"0",
      o_AN    => AN,
      o_EN    => SEG7_CATH);

  UP_BUTTON : entity work.debounce(rtl) 
    Port map(
      i_clk => CLK100MHZ,   -- 100 MHz clk
      i_rst => w_rst,
      i_pb  => BTNU,
      o_db  => w_db_up);
      
  LEFT_BUTTON : entity work.debounce(rtl) 
    Port map(
      i_clk => CLK100MHZ,   -- 100 MHz clk
      i_rst => w_rst,
      i_pb  => BTNL,
      o_db  => w_db_left);

  RIGHT_BUTTON : entity work.debounce(rtl) 
    Port map(
      i_clk => CLK100MHZ,   -- 100 MHz clk
      i_rst => w_rst,
      i_pb  => BTNR,
      o_db  => w_db_right);

  DOWN_BUTTON : entity work.debounce(rtl) 
    Port map(
      i_clk => CLK100MHZ,   -- 100 MHz clk
      i_rst => w_rst,
      i_pb  => BTND,
      o_db  => w_db_down);
    
 end architecture rtl;