----------------------------------------------------------------------------
--
--  Score Keeper : Module for converting the score into a 3 digit 7 segment display
--
--  This module takes in the score and outputs three 7 segment display signals for
--  each digit. The signals are then mapped onto the corresponding pixels on the screen
--  to display the score.
--
--  Revision History:
--  5/1/25  Alex Chen       Initial revision
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity score_keeper is
    Port ( score    : in integer range 0 to 999;            -- integer representing game score
           clk      : in std_logic;                         -- 8 MHz clock signal
           hundreds : out STD_LOGIC_VECTOR (6 downto 0);    -- hundreds digit 7 segment display
           tens     : out STD_LOGIC_VECTOR (6 downto 0);    -- tens digit 7 segment display
           ones     : out STD_LOGIC_VECTOR (6 downto 0)     -- ones digit 7 segment display
    );
end score_keeper;

architecture Behavioral of score_keeper is
    -- declare integer signals for the hundreds, tens, and ones digits
    signal hundreds_int :   integer range 0 to 9;
    signal tens_int     :   integer range 0 to 9;
    signal ones_int     :   integer range 0 to 9;
begin
    -- split the score into the hundreds, tens, and ones place
    hundreds_int <= score / 100;
    tens_int <= (score / 10) mod 10;
    ones_int <= score mod 10;
    
    process(clk)
    begin
        -- convert the hundreds int to a 7 segment signal
        case hundreds_int is
            when 0 =>
                hundreds <= (6 => '0', others => '1');
            when 1 =>
                hundreds <= (1 => '1', 2 => '1', others => '0');
            when 2 =>
                hundreds <= (2 => '0', 5 => '0', others => '1');
            when 3 =>
                hundreds <= (4 => '0', 5 => '0', others => '1');
            when 4 =>
                hundreds <= (0 => '0', 3 => '0', 4 => '0', others => '1');
            when 5 =>
                hundreds <= (1 => '0', 4 => '0', others => '1');
            when 6 =>
                hundreds <= (1 => '0', others => '1');
            when 7 =>
                hundreds <= (0 => '1', 1 => '1', 2 => '1', others => '0');
            when 8 =>
                hundreds <= (others => '1');
            when 9 =>
                hundreds <= (3 => '0', 4 => '0', others => '1');
        end case;
        
        -- convert the tens int to a 7 segment signal
        case tens_int is
            when 0 =>
                tens <= (6 => '0', others => '1');
            when 1 =>
                tens <= (1 => '1', 2 => '1', others => '0');
            when 2 =>
                tens <= (2 => '0', 5 => '0', others => '1');
            when 3 =>
                tens <= (4 => '0', 5 => '0', others => '1');
            when 4 =>
                tens <= (0 => '0', 3 => '0', 4 => '0', others => '1');
            when 5 =>
                tens <= (1 => '0', 4 => '0', others => '1');
            when 6 =>
                tens <= (1 => '0', others => '1');
            when 7 =>
                tens <= (0 => '1', 1 => '1', 2 => '1', others => '0');
            when 8 =>
                tens <= (others => '1');
            when 9 =>
                tens <= (3 => '0', 4 => '0', others => '1');
        end case;
        
        -- convert the ones int to a 7 segment signal
        case ones_int is
            when 0 =>
                ones <= (6 => '0', others => '1');
            when 1 =>
                ones <= (1 => '1', 2 => '1', others => '0');
            when 2 =>
                ones <= (2 => '0', 5 => '0', others => '1');
            when 3 =>
                ones <= (4 => '0', 5 => '0', others => '1');
            when 4 =>
                ones <= (0 => '0', 3 => '0', 4 => '0', others => '1');
            when 5 =>
                ones <= (1 => '0', 4 => '0', others => '1');
            when 6 =>
                ones <= (1 => '0', others => '1');
            when 7 =>
                ones <= (0 => '1', 1 => '1', 2 => '1', others => '0');
            when 8 =>
                ones <= (others => '1');
            when 9 =>
                ones <= (3 => '0', 4 => '0', others => '1');
        end case;
    end process;

end Behavioral;
