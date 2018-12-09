----------------------------------------------------------------------------------
-- Company:    JHU EP
-- Engineer:   Ryan Newport
-- 
-- Create Date:   12/09/2018 
-- Module Name:   clk_div_frac
-- Project Name:  Final Project
--
-- Description:  Fractional clock divider from URL below. 
-- Uses Dual Modulus Prescaler algorithm
-- http://vhdlguru.blogspot.com/2013/08/fractional-clock-division-dual-modulus.html
--
--
-- f_in  - the frequency of the input wave.
-- f_out - the frequency of the output wave.
-- f_acc - the channel spacing frequency(accuracy of the system).
--
--
--
-----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity clk_div_frac is
    port(
        reset  : in  std_logic; -- Active-High Synchronous Reset
        clock  : in  std_logic; -- Input Clock
        output : out std_logic  -- Output Baud Clock
    );
end clk_div_frac;

architecture implementation of clk_div_frac is

    -- change these parameters for changing the output freq(in hz).
     constant f_in  : real := 100000000.0; -- input freq.
     constant f_out : real := 1024000.0;  -- output freq.
     constant f_acc : real := 100.0; --  channel spacing frequency
     
     --NO need to edit the below lines.
    constant Total_Count : integer := integer(f_in/f_acc);  
    constant N : integer := integer(f_in/f_out)+1; -- N should always be P+1
    constant P : integer := N-1; -- P should always be N-1
     constant C : integer := Total_Count/P; -- Sequence Length
     constant B : integer := C-(Total_Count mod P); -- # of times to divide by P

    signal seq_ctr       : integer range 0 to C-1; -- Sequence Counter
    signal dual_mod_load : integer range 0 to N-1; -- Selected load value
    signal dual_mod_ctr  : integer range 0 to N-1; -- Dual Modulus Counter
    signal mux_select    : std_logic; -- Selects between N and P
    signal term_count    : std_logic; -- Dual Modulus Terminal Count
    signal divider       : std_logic; -- Output Divider

begin

    -- This is the sequence counter. Count from C-1 downto 0. Enabled only
    -- when term_count is active. If count is 0, then reload to C-1
    pSeqCount: process(clock)
    begin
        if (rising_edge(clock)) then
            if (reset = '1') then
                seq_ctr <= 0;
            else
                if (term_count = '1') then
                    if (seq_ctr = 0) then
                        seq_ctr <= C-1;
                    else
                        seq_ctr <= seq_ctr - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- This is the comparison of the current sequence count to the value B
    mux_select <= '1' when (seq_ctr < B) else '0';

    -- This statement implements the modulus selection multiplexer
    dual_mod_load <= (P-1) when (mux_select = '1') else (N-1);

    -- This is the dual-modulus counter. Count from dual_mod_load downto 0.
    -- Counter auto reloads when terminal count is reached.
    pDualModCount: process(clock)
    begin
        if (rising_edge(clock)) then
            if (reset = '1') then
                dual_mod_ctr <= 0;
            else
                if (term_count = '1') then
                    dual_mod_ctr <= dual_mod_load;
                else
                    dual_mod_ctr <= dual_mod_ctr - 1;
                end if;
            end if;
        end if;
    end process;

    -- Detect the terminal count condition
    term_count <= '1' when (dual_mod_ctr = 0) else '0';

    -- The output divide-by-two counter
    pDivider: process(clock)
    begin
        if (rising_edge(clock)) then
            if (reset = '1') then
                divider <= '0';
            elsif (term_count = '1') then
                divider <= not(divider);
            end if;
        end if;
    end process;

    -- Module Output
    output <= divider;

end implementation;