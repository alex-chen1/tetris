library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity block_memory is
    Port (
        start_place     :   in std_logic;
        clk             :   in std_logic;
        fall_board      :   in boardSize;
        game_board      :   in boardSize;
        combined_board  :   out boardSize;
        done_place      :   out std_logic
    );
end block_memory;

architecture Behavioral of block_memory is
signal start_place_vector : std_logic_vector(1 downto 0);
begin
process(clk)
begin
    start_place_vector <= start_place_vector(0) & start_place;
    if rising_edge(clk) then
        if start_place_vector = "01" then
            RowOr : for i in 0 to rows - 1 loop
                ColOr : for j in 0 to cols - 1 loop
                    combined_board(i)(j) <= game_board(i)(j) or fall_board(i)(j);
                end loop ColOr;
            end loop RowOr;
            done_place <= '1';
        else
            done_place <= '0';
        end if;
    end if;
end process;
end Behavioral;
