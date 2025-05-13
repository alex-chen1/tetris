----------------------------------------------------------------------------
--
--  Line Clear : Module for clearing the lines of the game board and incrementing the score
--
--  This module takes in the game board before the line clears, then outputs the score 
--  as three 7 segment signals and the game board after the lines are cleared.
--
--  Revision History:
--  5/1/25  Alex Chen       Initial revision
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity line_clear is
    Port (
        clear_board         :   in std_logic;           -- signal to clear the lines on the board
        game_board          :   in boardSize;           -- current game board
        game_board_cleared  :   buffer boardSize;       -- game board after clearing the lines
        clk                 :   in std_logic;           -- 8 MHz clock signal
        hundreds : out STD_LOGIC_VECTOR (6 downto 0);   -- hundreds digit 7 segment signal
        tens     : out STD_LOGIC_VECTOR (6 downto 0);   -- tens digit 7 segment signal
        ones     : out STD_LOGIC_VECTOR (6 downto 0)    -- ones digit 7 segment signal
    );
end line_clear;

architecture Behavioral of line_clear is

    -- declare score keeper component
    component score_keeper
        Port (
            score    : in integer range 0 to 999;
            clk      : in std_logic;
            hundreds : out STD_LOGIC_VECTOR (6 downto 0);
            tens     : out STD_LOGIC_VECTOR (6 downto 0);
            ones     : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    signal score    :   integer range 0 to 999 := 0;                    -- game score, capped at 999
    signal row_cleared  :   integer range 0 to rows - 1 := rows - 1;    -- index for game_board_cleared

begin
    -- instantiate the score keeper
    ScoreKeeper : score_keeper port map (   score => score,
                                            clk => clk,
                                            hundreds => hundreds,
                                            tens => tens,
                                            ones => ones);

process(clk)
begin
    -- if the clk and clear_board signals are rising
    if rising_edge(clk) and rising_edge(clear_board) then
        -- initialize game_board_cleared as empty
        game_board_cleared <= (others => (others => '0'));
        -- iterate through each row in the bottom up direction
        for row in rows - 1 downto 0 loop
            -- if a row is full, increment the score
            if game_board(row) = (0 to cols - 1 => '1') then
                score <= score + 1;
            -- else, copy the row to the output
            else
                game_board_cleared(row_cleared) <= game_board(row);
                if row_cleared > 0 then
                    row_cleared <= row_cleared - 1;
                end if;
            end if;
        end loop;
    end if;
end process;
end Behavioral;
