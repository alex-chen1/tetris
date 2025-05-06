library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity line_clear is
    Port (
        clear_board         :   in std_logic;
        game_board          :   in boardSize;
        game_board_cleared  :   buffer boardSize;
        clk                 :   in std_logic;
        hundreds : out STD_LOGIC_VECTOR (6 downto 0);
        tens     : out STD_LOGIC_VECTOR (6 downto 0);
        ones     : out STD_LOGIC_VECTOR (6 downto 0)
    );
end line_clear;

architecture Behavioral of line_clear is

    component score_keeper
        Port (
            score    : in integer range 0 to 999;
            clk      : in std_logic;
            hundreds : out STD_LOGIC_VECTOR (6 downto 0);
            tens     : out STD_LOGIC_VECTOR (6 downto 0);
            ones     : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    signal score    :   integer range 0 to 999 := 0;
    signal row_cleared  :   integer range 0 to rows - 1 := rows - 1;

begin
    ScoreKeeper : score_keeper port map (   score => score,
                                            clk => clk,
                                            hundreds => hundreds,
                                            tens => tens,
                                            ones => ones);

process(clk)
begin
    if rising_edge(clk) and rising_edge(clear_board) then
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
