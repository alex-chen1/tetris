library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity block_memory is
    Port (
        place           :   in std_logic;
        clk             :   in std_logic;
        fall_board      :   in boardSize;
        game_board      :   in boardSize;
        combined_board  :   out boardSize
    );
end block_memory;

architecture Behavioral of block_memory is

begin
process(clk)
begin
    if rising_edge(clk) and rising_edge(place) then
        RowOr : for i in 0 to rows - 1 loop
            ColOr : for j in 0 to cols - 1 loop
                combined_board(i)(j) <= game_board(i)(j) or fall_board(i)(j);
            end loop ColOr;
        end loop RowOr;
    end if;
end process;
end Behavioral;
