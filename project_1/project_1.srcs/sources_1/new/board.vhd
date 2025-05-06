library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity board is
    Port (
        nReset      :   in std_logic;
        r           :   in std_logic_vector(8 downto 0);
        c           :   in std_logic_vector(9 downto 0);
        block_type  :   in STD_LOGIC_VECTOR(2 downto 0);
        clk         :   in std_logic;
        hundreds    :   in std_logic_vector(6 downto 0);
        tens        :   in std_logic_vector(6 downto 0);
        ones        :   in std_logic_vector(6 downto 0);
        game_board  :   in boardSize;
        vga_output  :   out std_logic
    );
end board;

architecture Behavioral of board is
    
    signal display              :   monitorSize := (others => (others => '0'));
    signal new_block            :   newBlockSize := (others => (others => '0'));
    
    constant vstart             :   integer := (screen_y - rows * (block_size + space)) / 2;
    constant hstart             :   integer := (screen_x - cols * (block_size + space) - hud_width) / 2;
    constant vend               :   integer := vstart + rows * (block_size + space);
    constant hend               :   integer := hstart + cols * (block_size + space);
    
    
    
    
begin
    GameBoardRows : for i in 0 to rows - 1 generate
        RowFill: for j in 0 to block_size - 1 generate
            GameBoardCols : for k in 0 to cols - 1 generate
                display(vstart + i * (block_size + space) + j + space / 2)(hstart + k * (block_size + space) + space / 2 to hstart + k * (block_size + space) + block_size + space / 2) <= (others => game_board(i)(k));
            end generate GameBoardCols;
        end generate RowFill;
    end generate GameBoardRows;
    
    NextBlockRows : for i in 0 to tetrominoes_size - 1 generate
        RowFill: for j in 0 to block_size - 1 generate
            NextBlockCols : for k in 0 to tetrominoes_size - 1 generate
                display(vstart + new_block_y_offset + i * (block_size + space) + j + space / 2)(hend + new_block_x_offset + k * (block_size + space) + space / 2 to hend + new_block_x_offset + k * (block_size + space) + block_size + space / 2) <= (others => new_block(i)(k));
            end generate NextBlockCols;
        end generate RowFill;
    end generate NextBlockRows;
    
    -- drawing "NEXT BLOCK" text
    -- draw "N"
    NVerticalLines : for i in 10 to 29 generate
        display(vstart + i)(hend + 50 to hend + 52) <= (others => '1');
        display(vstart + i)(hend + 62 to hend + 64) <= (others => '1');
    end generate NVerticalLines;
    NDiagonal : for i in 1 to 12 generate
        NDiagonalFill : for j in 11 to 15 generate
            display(vstart + i + j)(hend + 50 + i) <= '1';
        end generate NDiagonalFill;
    end generate NDiagonal;
    -- draw "E"
    EVerticalLine : for i in 10 to 29 generate
        display(vstart + i)(hend + 70 to hend + 72) <= (others => '1');
    end generate EVerticalLine;
    EHorizontalLines : for i in 10 to 12 generate
        display(vstart + i)(hend + 73 to hend + 84) <= (others => '1');
        display(vstart + i + 8)(hend + 73 to hend + 84) <= (others => '1');
        display(vstart + i + 17)(hend + 73 to hend + 84) <= (others => '1');
    end generate EHorizontalLines;
    -- draw "X"
    XDiagonals : for i in 0 to 14 generate
        XDiagonalsFill : for j in 11 to 14 generate
            display(vstart + i + j)(hend + 90 + i) <= '1';
            display(vstart + i + j)(hend + 104 - i) <= '1';
        end generate XDiagonalsFill;
    end generate XDiagonals;
    XEndCaps : for i in 10 to 14 generate
        display(vstart + i)(hend + 90 to hend + 94) <= (others => '1');
        display(vstart + i)(hend + 100 to hend + 104) <= (others => '1');
        display(vstart + i + 15)(hend + 90 to hend + 94) <= (others => '1');
        display(vstart + i + 15)(hend + 100 to hend + 104) <= (others => '1');
    end generate XEndCaps;
    -- draw "T"
    THorizontalLine : for i in 10 to 29 generate
        display(vstart + i)(hend + 116 to hend + 119) <= (others => '1');
    end generate THorizontalLine;
    TVerticalLine : for i in 10 to 12 generate
        display(vstart + i)(hend + 110 to hend + 124) <= (others => '1');
    end generate TVerticalLine;
    -- draw "B"
    BLeftVerticalLine : for i in 35 to 54 generate
        display(vstart + i)(hend + 40 to hend + 42) <= (others => '1');
    end generate BLeftVerticalLine;
    -- B corners, each have a sightly differnt length to draw the curve of the B
    display(vstart + 35)(hend + 40 to hend + 52) <= (others => '1');
    display(vstart + 36)(hend + 40 to hend + 53) <= (others => '1');
    display(vstart + 37)(hend + 40 to hend + 54) <= (others => '1');
    display(vstart + 43)(hend + 40 to hend + 53) <= (others => '1');
    display(vstart + 44)(hend + 40 to hend + 54) <= (others => '1');
    display(vstart + 45)(hend + 40 to hend + 53) <= (others => '1');
    display(vstart + 52)(hend + 40 to hend + 54) <= (others => '1');
    display(vstart + 53)(hend + 40 to hend + 53) <= (others => '1');
    display(vstart + 54)(hend + 40 to hend + 52) <= (others => '1');
    BRightVerticalLine : for i in 38 to 51 generate
        display(vstart + i)(hend + 52 to hend + 54) <= (others => '1');
    end generate BRightVerticalLine;
    -- draw "L"
    LVerticalLine : for i in 35 to 54 generate
        display(vstart + i)(hend + 60 to hend + 62) <= (others => '1');
    end generate LVerticalLine;
    LHorizontalLine : for i in 52 to 54 generate
        display(vstart + i)(hend + 60 to hend + 74) <= (others => '1');
    end generate LHorizontalLine;
    -- draw "O"
    OVerticalLines : for i in 35 to 54 generate
        display(vstart + i)(hend + 80 to hend + 82) <= (others => '1');
        display(vstart + i)(hend + 92 to hend + 94) <= (others => '1');
    end generate OVerticalLines;
    OHorizontalLines : for i in 35 to 37 generate
        display(vstart + i)(hend + 80 to hend + 94) <= (others => '1');
        display(vstart + i + 17)(hend + 80 to hend + 94) <= (others => '1');
    end generate OHorizontalLines;
    -- draw "C"
    CVerticalLine : for i in 35 to 54 generate
        display(vstart + i)(hend + 100 to hend + 102) <= (others => '1');
    end generate CVerticalLine;
    CHorizontalLines : for i in 35 to 37 generate
        display(vstart + i)(hend + 100 to hend + 114) <= (others => '1');
        display(vstart + i + 17)(hend + 100 to hend + 114) <= (others => '1');
    end generate CHorizontalLines;
    -- draw "K"
    KDiagonals : for i in 0 to 8 generate
        KDiagonalsFill : for j in 35 to 39 generate
            display(vstart + i + j + 7)(hend + 122 + i) <= '1';
            display(vstart + i + j)(hend + 130 - i) <= '1';
        end generate KDiagonalsFill;
    end generate KDiagonals;
    KVerticalLine : for i in 35 to 54 generate
        display(vstart + i)(hend + 120 to hend + 122) <= (others => '1');
    end generate KVerticalLine;
    KEndCaps1 : for i in 0 to 1 generate
        display(vstart + 35 + i)(hend + 133) <= '1';
        display(vstart + 53 + i)(hend + 133) <= '1';
    end generate KEndCaps1;
    KEndCaps2 : for i in 0 to 2 generate
        display(vstart + 35 + i)(hend + 132) <= '1';
        display(vstart + 52 + i)(hend + 132) <= '1';
    end generate KEndCaps2;
    KEndCaps3 : for i in 0 to 3 generate
        display(vstart + 35 + i)(hend + 131) <= '1';
        display(vstart + 51 + i)(hend + 131) <= '1';
    end generate KEndCaps3;
    -- draw "L"
    LVerticalLine2 : for i in 50 to 69 generate
        display(vstart + hud_div_height + i)(hend + 40 to hend + 43) <= (others => '1');
    end generate LVerticalLine2;
    LHorizontalLine2 : for i in 67 to 69 generate
        display(vstart + hud_div_height + i)(hend + 40 to hend + 55) <= (others => '1');
    end generate LHorizontalLine2;
    -- draw "I"
    IVerticalLine : for i in 50 to 69 generate
        display(vstart + hud_div_height + i)(hend + 66 to hend + 69) <= (others => '1');
    end generate IVerticalLine;
    IHorizontalLines : for i in 50 to 52 generate
        display(vstart + hud_div_height + i)(hend + 60 to hend + 74) <= (others => '1');
        display(vstart + hud_div_height + i + 17)(hend + 60 to hend + 74) <= (others => '1');
    end generate IHorizontalLines;
    -- draw "N"
    NVerticalLines2 : for i in 50 to 69 generate
        display(vstart + hud_div_height + i)(hend + 80 to hend + 82) <= (others => '1');
        display(vstart + hud_div_height + i)(hend + 92 to hend + 94) <= (others => '1');
    end generate NVerticalLines2;
    NDiagonal2 : for i in 1 to 12 generate
        NDiagonalFill2 : for j in 51 to 54 generate
            display(vstart + hud_div_height + i + j)(hend + 80 + i) <= '1';
        end generate NDiagonalFill2;
    end generate NDiagonal2;
    -- draw "E"
    EVerticalLine2 : for i in 50 to 69 generate
        display(vstart + hud_div_height + i)(hend + 100 to hend + 102) <= (others => '1');
    end generate EVerticalLine2;
    EHorizontalLines2 : for i in 50 to 52 generate
        display(vstart + hud_div_height + i)(hend + 103 to hend + 115) <= (others => '1');
        display(vstart + hud_div_height + i + 8)(hend + 103 to hend + 115) <= (others => '1');
        display(vstart + hud_div_height + i + 17)(hend + 103 to hend + 115) <= (others => '1');
    end generate EHorizontalLines2;
    -- draw "S"
    SVerticalLines : for i in 50 to 60 generate
        display(vstart + hud_div_height + i)(hend + 120 to hend + 122) <= (others => '1');
        display(vstart + hud_div_height + i + 9)(hend + 132 to hend + 134) <= (others => '1');
    end generate SVerticalLines;
    SHorizontalLines : for i in 50 to 52 generate
        display(vstart + hud_div_height + i)(hend + 120 to hend + 134) <= (others => '1');
        display(vstart + hud_div_height + i + 8)(hend + 120 to hend + 134) <= (others => '1');
        display(vstart + hud_div_height + i + 17)(hend + 120 to hend + 134) <= (others => '1');
    end generate SHorizontalLines;
    
    -- draw score (7 segment)
    -- draw hundreds place
    HundredsHorizontalLines : for i in 100 to 102 generate
        display(vstart + hud_div_height + i)(hend + 63 to hend + 71) <= (others => hundreds(0));
        display(vstart + hud_div_height + i + 18)(hend + 63 to hend + 71) <= (others => hundreds(3));
        display(vstart + hud_div_height + i + 9)(hend + 63 to hend + 71) <= (others => hundreds(6));
    end generate HundredsHorizontalLines;
    HundredsVerticalLines : for i in 103 to 109 generate
        display(vstart + hud_div_height + i)(hend + 72 to hend + 74) <= (others => hundreds(1));
        display(vstart + hud_div_height + i + 9)(hend + 72 to hend + 74) <= (others => hundreds(2));
        display(vstart + hud_div_height + i + 9)(hend + 60 to hend + 62) <= (others => hundreds(4));
        display(vstart + hud_div_height + i)(hend + 60 to hend + 62) <= (others => hundreds(5));
    end generate HundredsVerticalLines;
    -- draw tens place
    TensHorizontalLines : for i in 100 to 102 generate
        display(vstart + hud_div_height + i)(hend + 83 to hend + 91) <= (others => tens(0));
        display(vstart + hud_div_height + i + 18)(hend + 83 to hend + 91) <= (others => tens(3));
        display(vstart + hud_div_height + i + 9)(hend + 83 to hend + 91) <= (others => tens(6));
    end generate TensHorizontalLines;
    TensVerticalLines : for i in 103 to 109 generate
        display(vstart + hud_div_height + i)(hend + 92 to hend + 94) <= (others => tens(1));
        display(vstart + hud_div_height + i + 9)(hend + 92 to hend + 94) <= (others => tens(2));
        display(vstart + hud_div_height + i + 9)(hend + 80 to hend + 82) <= (others => tens(4));
        display(vstart + hud_div_height + i)(hend + 80 to hend + 82) <= (others => tens(5));
    end generate TensVerticalLines;
    -- draw ones place
    OnesHorizontalLines : for i in 100 to 102 generate
        display(vstart + hud_div_height + i)(hend + 103 to hend + 111) <= (others => ones(0));
        display(vstart + hud_div_height + i + 18)(hend + 103 to hend + 111) <= (others => ones(3));
        display(vstart + hud_div_height + i + 9)(hend + 103 to hend + 111) <= (others => ones(6));
    end generate OnesHorizontalLines;
    OnesVerticalLines : for i in 103 to 109 generate
        display(vstart + hud_div_height + i)(hend + 112 to hend + 114) <= (others => ones(1));
        display(vstart + hud_div_height + i + 9)(hend + 112 to hend + 114) <= (others => ones(2));
        display(vstart + hud_div_height + i + 9)(hend + 100 to hend + 102) <= (others => ones(4));
        display(vstart + hud_div_height + i)(hend + 100 to hend + 102) <= (others => ones(5));
    end generate OnesVerticalLines;
    
    -- draw frames (framing lines for the board, not video frames)
    VerticalFrames : for i in vstart - block_size - space - 5 to vend + block_size + space - 1 generate
        display(i)(hstart - block_size - space - 5 to hstart - block_size - space - 1) <= (others => '1');
        display(i)(hend + block_size + space to hend + block_size + space + 4) <= (others => '1');
        display(i)(hend + hud_width to hend + hud_width + 4) <= (others => '1');
    end generate VerticalFrames;
    VerticalGameBoardFrames : for i in vstart - 1 to vend generate
        display(i)(hstart - 5 to hstart - 1) <= (others => '1');
        display(i)(hend + 1 to hend + 5) <= (others => '1');
    end generate VerticalGameBoardFrames;
    HorizontalFrames : for i in 0 to 4 generate
        display(vstart - block_size - space - 5 + i)(hstart - block_size - space - 5 to hend + hud_width - 1) <= (others => '1');
        display(vend + block_size + space + i)(hstart - block_size - space - 5 to hend + hud_width + 4) <= (others => '1');
        display(vstart + hud_div_height + i)(hend + block_size + space to hend + hud_width + 4) <= (others => '1');
        display(vstart - i - 1)(hstart - 5 to hend + 5) <= (others => '1');
        display(vend + i + 1)(hstart - 5 to hend + 5) <= (others => '1');
    end generate HorizontalFrames;
    
        
    
    process(clk)
    begin
        case block_type is
            when "001" => 
                new_block(0) <= (others => '0');
                new_block(1) <= (others => '1');
                new_block(2) <= (others => '0');
                new_block(3) <= (others => '0');
            when "010" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (0 => '0', others => '1');
                new_block(2) <= (3 => '1', others => '0');
                new_block(3) <= (others => '0');
            when "011" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (0 => '0', others => '1');
                new_block(2) <= (1 => '1', others => '0');
                new_block(3) <= (others => '0');
            when "100" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (3 => '0', others => '1');
                new_block(2) <= (1 => '1', others => '0');
                new_block(3) <= (others => '0');
            when "101" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (1 => '1', 2 => '1', others => '0');
                new_block(2) <= (1 => '1', 2 => '1', others => '0');
                new_block(3) <= (others => '0');
            when "110" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (0 => '1', 1 => '1', others => '0');
                new_block(2) <= (1 => '1', 2 => '1', others => '0');
                new_block(3) <= (others => '0');
            when "111" =>
                new_block(0) <= (others => '0');
                new_block(1) <= (2 => '1', 3 => '1', others => '0');
                new_block(2) <= (1 => '1', 2 => '1', others => '0');
                new_block(3) <= (others => '0');
            when others =>
                new_block <= (others => (others => '0'));
        end case;
            
        vga_output <= display(to_integer(unsigned(r)))(to_integer(unsigned(c)));
    end process;
        

end Behavioral;
