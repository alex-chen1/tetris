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

entity falling_block_TB is
end falling_block_TB;

architecture TB_ARCHITECTURE of falling_block_TB is
    -- component declaration of the tested unit
    component falling_block is
        Port (
            block_type      :   in std_logic_vector(2 downto 0);    -- signal to
            new_fall        :   in std_logic;                       -- start a new block and its fall
            clk             :   in std_logic;                       -- 8 MHz clock
            game_clk        :   in std_logic;                       -- 60 Hz clock, corresponds to monitor refresh rate
            left            :   in std_logic;                       -- move the falling block left
            right           :   in std_logic;                       -- move the falling block right
            up              :   in std_logic;                       -- rotate the falling block clockwise
            place           :   in std_logic;                       -- instantly place the falling block
            done_fall       :   out std_logic;                      -- block is done falling and has been placed
            game_board      :   in boardSize;                       -- array with all the game board spaces that contain a placed block
            fall_board      :   buffer boardSize                    -- array with all the game board spaces that contain the falling block
        );
    end component;
    
    -- clock signal
    signal clk              :   std_logic;
    signal game_clk         :   std_logic;
    
    -- signals mapped to input of tested entity
    signal block_type       :   std_logic_vector(2 downto 0);
    signal new_fall         :   std_logic;
    signal left             :   std_logic;
    signal right            :   std_logic;
    signal up               :   std_logic;
    signal place            :   std_logic;
    signal done_fall        :   std_logic;
    signal game_board       :   boardSize;
    signal fall_board       :   boardSize;
    
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
    UUT : falling_block
        port map (
            block_type => block_type,
            new_fall => new_fall,
            clk => clk,
            game_clk => game_clk,
            left => left,
            right => right,
            up => up,
            place => place,
            done_fall => done_fall,
            game_board => game_board,
            fall_board => fall_board
        );
        
    process
        variable  lo      :  line;     --  output line
        
    begin
        -- check I block rot 0
        left <= '0';
        right <= '0';
        up <= '0';
        place <= '0';
        block_type <= "001";
        new_fall <= '0';
        game_board <= (others => (others => '0'));
        wait for 250 ns;
        new_fall <= '1';
        wait for 10 ns;
        place <= '1';
        wait for 10 ns;
        place <= '0';
        assert(std_match(fall_board(0), "0001111000"))
            report "I block rot 0 failure"
            severity error;
        wait for 10 ns;
        new_fall <= '0';
        wait for 20 ns;
        
        -- check I block rot 1
        new_fall <= '0';
        up <= '0';
        game_board <= (others => (others => '0'));
        wait for 250 ns;
        new_fall <= '1';
        wait for 10 ns;
        up <= '1';
        wait for 10 ns;
        up <= '0';
        place <= '1';
        wait for 10 ns;
        place <= '0';
        assert(std_match(fall_board(0), "0000100000"))
            report "I block rot 1 failure"
            severity error;
        assert(std_match(fall_board(1), "0000100000"))
            report "I block rot 1 failure"
            severity error;
        assert(std_match(fall_board(2), "0000100000"))
            report "I block rot 1 failure"
            severity error;
        assert(std_match(fall_board(3), "0000100000"))
            report "I block rot 1 failure"
            severity error;
        wait for 10 ns;
        new_fall <= '0';
        wait for 20 ns;
        
        
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

configuration TESTBENCH_FOR_BOARD of falling_block_TB is
    for TB_ARCHITECTURE
	   for UUT : falling_block
            use entity work.falling_block(Behavioral);
	   end for;
    end for;
end TESTBENCH_FOR_BOARD;