----------------------------------------------------------------------------------
--
--  Pong Game Board Processing Element Test Bench
--  
--  This file contains a test bench for the Board processing element of the Pong Game.
--  It tests that the processing element correctly outputs the scores of both players
--  in both BCD and in the display.
-- 
--  Revision History:
--  06 Mar 25   Alex Chen   initial revision, simple manual test checks only
--                          TODO: have this test bench output to a text file, then
--                              a python script reads in the text file and displays it
----------------------------------------------------------------------------------

-- import libs
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.utilities.all;

entity Board_TB is
end Board_TB;

architecture TB_ARCHITECTURE of Board_TB is
    -- component declaration of the tested unit
    component week421
        Port (
            nReset              :   in std_logic;
            start_game          :   in std_logic;
            r                   :   in std_logic_vector(8 downto 0);
            c                   :   in std_logic_vector(9 downto 0);
            clk                 :   in std_logic;
            game_clk            :   in std_logic;
            hundreds            :   inout STD_LOGIC_VECTOR (6 downto 0);
            tens                :   inout STD_LOGIC_VECTOR (6 downto 0);
            ones                :   inout STD_LOGIC_VECTOR (6 downto 0);
            vga_output          :   out std_logic
        );
    end component;
    
    -- clock signal
    signal clk              :   std_logic;
    signal game_clk         :   std_logic;
    
    -- signals mapped to input of tested entity
    signal nReset           :   std_logic;
    signal start_game       :   std_logic;
    signal r                :   std_logic_vector(8 downto 0);
    signal c                :   std_logic_vector(9 downto 0);
    
    -- signals mapped to output of tested entity
    signal hundreds         :   std_logic_vector(6 downto 0);
    signal tens             :   std_logic_vector(6 downto 0);
    signal ones             :   std_logic_vector(6 downto 0);
    signal vga_output       :   std_logic;
    
    -- helper signal for writing output to file
    signal outputVector     :   std_logic_vector(0 to 480 * 640 - 1);
    
    -- signal to end the simulation
    signal END_SIM          :   boolean := false;
    
    --  log for test vector out
    file fout               :  text open write_mode is "../output.txt";
    
    
    -- shift 9 bits into the cell array, LSB first, used to test 3x3 base cases
    procedure printOutput (
                    signal r        :       out std_logic_vector(8 downto 0);
                    signal c        :       out std_logic_vector(9 downto 0);
                    file fout       :       text;
                    variable lo     :       inout line;
                    signal output   :       in std_logic;
                    signal outputVector    :   inout std_logic_vector(0 to 480 * 640 - 1)) is
    begin
        
        if not END_SIM then
            for row in 0 to 479 loop
                for col in 0 to 639 loop
                    r <= std_logic_vector(to_unsigned(row, 9));
                    c <= std_logic_vector(to_unsigned(col, 10));
                    wait for 10 ns;
                    outputVector(640 * row + col) <= output;
                end loop;
            end loop;
            
            -- write output to file
            write(lo, outputVector);
            writeline(fout, lo);
            
        end if;
    end printOutput;
    
    procedure fastTest (
                    file fout           :       text;
                    variable lo         :       inout line;
                    signal game_board   : boardSize) is
    begin
        if not END_SIM then
            for row in 0 to rows - 1 loop
                -- write output to file
                write(lo, game_board(row));
                writeline(fout, lo);
            end loop;
        end if;
    end fastTest;
    
begin
    -- Unit Under Test Port Map
    UUT : week421
        port map (
            nReset => nReset,
            start_game => start_game,
            r => r,
            c => c,
            clk => clk,
            game_clk => game_clk,
            hundreds => hundreds,
            tens => tens,
            ones => ones,
            vga_output => vga_output
        );
        
    process
        variable  lo      :  line;     --  output line
        
    begin
        -- print the starting screen
        start_game <= '0';
        wait for 10 ns;
        start_game <= '1';
        wait for 100 ns;
        start_game <= '0';
--        printOutput(r, c, fout, lo, vga_output, outputVector);
        wait for 1 us;
        END_SIM <= true;
    end process;
    
    -- process to generate a 10 ns period, 50% duty cycle clock, generate until simulation ends
    CLOCK_CLK : process
    begin
    
        if END_SIM = FALSE then
            clk <= '0';
            wait for 5 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            clk <= '1';
            wait for 5 ns;
        else
            wait;
        end if;

    end process;
    
    -- process to generate a 100 ns period, 50% duty cycle clock, generate until simulation ends
    GAME_CLOCK_CLK : process
    begin
        if END_SIM = FALSE then
            game_clk <= '0';
            wait for 50 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            game_clk <= '1';
            wait for 50 ns;
        else
            wait;
        end if;

    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_BOARD of Board_TB is
    for TB_ARCHITECTURE
	   for UUT : week421
            use entity work.week421(Structural);
	   end for;
    end for;
end TESTBENCH_FOR_BOARD;