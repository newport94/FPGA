----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:    10/21/2018 
-- Module Name:    lab05_top
-- Project Name:   Lab05
-- Target Device:  Xilinx Artix-7 xc7a100tcsg324-1
--
-- Description:  top level entity for lab 05 picoblaze
--------------------------------------------------------------------------------------
--  OPERATIONS
--    Result         : 16 bit result stored in two 8-bit registers (starts at zero)
--    First operand  : 4-bit switch input
--    Second operand : 16-bit value above
--    OP REG,SW
--
--  BUTTONS
--    BTN_R : initiates operation (one per press)
--    BTN_D : resets 16-bit reg value to zero
--
--  SWITCHES
--    SW[7..4] : operation to peform after BTN_R pressed
--         SW[7] : multiplication (NO wrap around)
--         SW[6] : left shift     (NO wrap around)
--         SW[5] : subtract       (wraps around)
--         SW[4] : add            (wraps around)
--    SW[3..0] : 4-bit operand input value
--
--  DISPLAY
--    7SEG[7..4] : 0x0000 or debugging
--    7SEG[3..0] : Displays 16-bit result
--
--  PRECEDENCE 
--    ADD > SUBTRACT > LEFT SHIFT > MULTIPLICATION
--
--  NEXYS-4 PORT IDs
--    case port_id is
--    when x"00"  => in_port <= status_register;
--    when x"01"  => in_port <= data_from_uartrx;
--    when x"02"  => in_port <= sliders;
--    when x"03"  => in_port <= x"0" & buttons;
--    when x"04"  => in_port <= seg7chars(7 downto 0);
--    when x"05"  => in_port <= seg7chars(15 downto 8);
--    when x"06"  => in_port <= leds_reg;
--    when x"07"  => in_port <= mstimer(7 downto 0);
--    when x"08"  => in_port <= mstimer(15 downto 8);
--    when others => in_port <= x"5a";
--    end case;
--
------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity lab05_top is 
  Port(
  
  
  );
end entity lab05_top;

architecture rtl of lab05_top is



begin





end architecture rtl;