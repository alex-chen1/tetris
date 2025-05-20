----------------------------------------------------------------------------
--
--  Falling Block: Module for the TETRIS game's falling block (block in play)
--
--  This module handles the left, right, rotate, and instantly place inputs
--  and accordingly moves the current block that falls. The module takes in
--  an array with the current game board and handles collision detection
--  when processing the inputs.
--
--  Revision History:
--  5/1/25  Alex Chen       Initial revision
--  5/2/25  Alex Chen       Added processing for left, right, place inputs
--  5/5/25  Alex Chen       Added processing for up (rotate) input
--  5/9/25  Alex Chen       Added wall kicking for rotations
--  5/12/25 Alex Chen       Adjusted some signals to be synced with clk
--
--  TODO:
--  handle game over (block spawns and overflows)
--  when block falls, have a different case for rotations
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity falling_block is
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
end falling_block;

architecture Behavioral of falling_block is

constant xstart : integer := 0;                                                 -- starting x coordinate (row) of the falling block
constant ystart : integer := cols / 2 - 1;                                      -- starting y coordinate (column), center column tie broken to the left, of the falling block
signal x : integer range 0 to rows - 1;                                         -- x coordinate (row)
signal y : integer range 0 to cols - 1;                                         -- y coordinate (column)
signal rot : integer range 0 to 3;                                              -- rotation state of the falling block
signal game_board_buffer : boardWBufferSize := (others => (others => '1'));     -- game board extended with a 3 block margin of 1s on each side
signal game_clk_sync : std_logic_vector(1 downto 0);                            -- synced game clock signal
signal left_sync : std_logic_vector(1 downto 0);                                -- synced left input signal
signal right_sync : std_logic_vector(1 downto 0);                               -- synced right input signal
signal up_sync : std_logic_vector(1 downto 0);                                  -- synced up input signal
signal place_sync : std_logic_vector(1 downto 0);                               -- synced place signal
signal new_fall_sync : std_logic_vector(1 downto 0);                            -- synced new fall signal

begin

-- map the game board to the game_board_buffer
GameBoardMap : for i in 0 + 3 to rows - 1 + 3 generate
    game_board_buffer(i)(0 + 3 to cols - 1 + 3) <= game_board(i - 3);
end generate GameBoardMap;

process(clk)
-- declare variables to indicate whether or not we can move left, right, or rotate after collision detection
variable can_left : boolean := false;
variable can_right : boolean := false;
variable can_rot : boolean := false;
variable can_fall : boolean := false;
variable vx : integer range 0 to rows - 1 := 0;
variable vy : integer range 0 to cols - 1 := 0;
variable vfall_board : boardSize;
begin
    if rising_edge(clk) then
        -- if the place_sync signal is rising, then place the block
        can_left := false;
        can_right := false;
        can_rot := false;
        can_fall := false;
        vx := x;
        vy := y;
        vfall_board := fall_board;
        if place_sync = "01" then
            case block_type is
                when "001" =>
                    case rot is
                        when 0 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3 to vy + 2 + 3) = "0000" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 =>
                            while game_board_buffer(vx + 3 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 2 =>
                            while game_board_buffer(vx + 2 + 3)(vy - 1 + 3 to vy + 2 + 3) = "0000" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);                             
                            end loop;
                        when 3 =>
                            while game_board_buffer(vx + 3 + 3)(vy + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when "010" => 
                    case rot is
                        when 0 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3 to vy + 1 + 3) = "000" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 2 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3 to vy + 3) = "00" and game_board_buffer(vx + 2 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 3 =>
                            while game_board_buffer(vx + 2 + 3)(vy - 1 + 3 to vy + 3) = "00" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when "011" =>
                    case rot is
                        when 0 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3 to vy + 1 + 3) = "000" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3 to vy + 1 + 3) = "00" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 2 =>
                            while game_board_buffer(vx + 1 + 3)(vy + 3 to vy + 1 + 3) = "00" and game_board_buffer(vx + 2 + 3)(vy - 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 3 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 3)(vy - 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when "100" =>
                    case rot is
                        when 0 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3) = '0' and game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 1 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 1 + 3)(vy - 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 2 =>
                            while game_board_buffer(vx + 1 + 3)(vy - 1 + 3 to vy + 1 + 3) = "000" loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 3 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 1 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when "101" =>
                    while game_board_buffer(vx + 1 + 3)(vy + 3 to vy + 1 + 3) = "00" loop
                        vx := vx + 1;
                        vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                    end loop;
                when "110" =>
                    case rot is
                        when 0 | 2 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3 to vy + 1 + 3) = "00" and game_board_buffer(vx + 1 + 3)(vy - 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 | 3 =>
                            while game_board_buffer(vx + 2 + 3)(vy + 3) = '0' and game_board_buffer(vx + 1 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when "111" =>
                    case rot is
                        when 0 | 2 =>
                            while game_board_buffer(vx + 2 + 3)(vy - 1 + 3 to vy + 3) = "00" and game_board_buffer(vx + 1 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                        when 1 | 3 =>
                            while game_board_buffer(vx + 1 + 3)(vy + 3) = '0' and game_board_buffer(vx + 2 + 3)(vy + 1 + 3) = '0' loop
                                vx := vx + 1;
                                vfall_board := vfall_board(rows - 1) & vfall_board(0 to rows - 2);
                            end loop;
                    end case;
                when others =>
            end case;
            x <= vx;
            y <= vy;
            done_fall <= '1';
            fall_board <= vfall_board;
        else
            -- if the left_sync signal is rising
            if left_sync = "01" then
                -- initially assume we cannot shift left
                can_left := false;
                case block_type is
                    -- for each block type
                        -- for each rotation
                            -- if the neighboring squares to the left of the block are empty, set can_left to true
                    when "001" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when "010" => 
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x - 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when "011" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when "100" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when "101" =>
                        if game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                            can_left := true;
                        end if;
                    when "110" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when "111" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3) = '0' then
                                    can_left := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    can_left := true;
                                end if;
                        end case;
                    when others =>
                end case;
                
                -- if the block can shift left, then shift it and update the y coordinate
                if can_left then
                    y <= y - 1;
                    for i in 0 to rows - 1 loop
                        fall_board(i) <= fall_board(i)(1 to cols - 1) & fall_board(i)(0);
                    end loop;
                end if;
                
            -- if the right_sync signal is rising
            elsif right_sync = "01" then
                -- initally assume we cannot shift right
                can_right := false;
                case block_type is
                    -- for each block type
                        -- for each rotation
                            -- if the neighboring squares to the right of the block are empty, set can_left to true
                    when "001" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y + 3 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 1)(y + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when "010" => 
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when "011" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when "100" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when "101" =>
                        if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                            can_right := true;
                        end if;
                    when "110" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when "111" =>
                        case rot is
                            when 0 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 1 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 2 =>
                                if game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    can_right := true;
                                end if;
                            when 3 =>
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    can_right := true;
                                end if;
                        end case;
                    when others =>
                end case;
                
                -- if the block can shift right, then shift it and update the y coordinate
                if can_right then
                    y <= y + 1;
                    for i in 0 to rows - 1 loop
                        fall_board(i) <= fall_board(i)(cols - 1) & fall_board(i)(0 to cols - 2);
                    end loop;
                end if;
            end if;
            
            -- if the up_sync signal is rising
            if up_sync = "01" then
                -- initially assume we cannot rotate
                can_rot := false;
                case block_type is
                    -- for each block type
                        -- for each rotation
                            -- check if the image of the rotation is empty on game_board_buffer
                            -- also check up to 4 more displacements of the rotation, this is called "wall kicking"
                            -- if any of the displacements are empty on game_borad_buffer, rotate the fall_board block accordingly and mark can_rot as true
                    when "001" =>
                        case rot is
                            when 0 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y + 1) <= '1';
                                    fall_board(x + 1)(y + 1) <= '1';
                                    fall_board(x + 2)(y + 1) <= '1';
                                    can_rot := true;
                                -- (0, -2)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1) <= '1';
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1) <= '1';
                                    y <= y - 2;
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 2 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 2) <= '1';
                                    fall_board(x)(y + 2) <= '1';
                                    fall_board(x + 1)(y + 2) <= '1';
                                    fall_board(x + 2)(y + 2) <= '1';
                                    y <= y + 1;
                                    can_rot := true;
                                -- (1, -2)
                                elsif game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1) <= '1';
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1) <= '1';
                                    fall_board(x + 3)(y - 1) <= '1';
                                    x <= x + 1;
                                    y <= y - 2;
                                    can_rot := true;
                                -- (-2, 1)
                                elsif game_board_buffer(x - 3 + 3)(y + 2 + 3) = '0' and game_board_buffer(x - 2 + 3)(y + 2 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y + 2) <= '1';
                                    fall_board(x - 2)(y + 2) <= '1';
                                    fall_board(x - 1)(y + 2) <= '1';
                                    fall_board(x)(y + 2) <= '1';
                                    x <= x - 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 1 =>
                                -- (0, 0)
                                if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 2 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1 to y + 2) <= (others => '1');
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 2 + 3 to y + 1 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 2 to y + 1) <= (others => '1');
                                    y <= y - 1;
                                    can_rot := true;
                                -- (0, 2)
                                elsif game_board_buffer(x + 1 + 3)(y + 1 + 3 to y + 4 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y + 1 to y + 4) <= (others => '1');
                                    y <= y + 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 2 + 3 to y + 1 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 2 to y + 1) <= (others => '1');
                                    x <= x - 2;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, 2)
                                elsif game_board_buffer(x + 2 + 3)(y + 1 + 3 to y + 4 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 2)(y + 1 to y + 4) <= (others => '1');
                                    x <= x + 1;
                                    y <= y + 2;
                                    can_rot := true;
                                end if;
                            when 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y) <= '1';
                                    can_rot := true;
                                -- (0, 2)
                                elsif game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 2 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 2) <= '1';
                                    fall_board(x)(y + 2) <= '1';
                                    fall_board(x + 1)(y + 2) <= '1';
                                    fall_board(x + 2)(y + 2) <= '1';
                                    y <= y + 2;
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1) <= '1';
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, 2)
                                elsif game_board_buffer(x - 2 + 3)(y + 2 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y + 2) <= '1';
                                    fall_board(x - 1)(y + 2) <= '1';
                                    fall_board(x)(y + 2) <= '1';
                                    fall_board(x + 1)(y + 2) <= '1';
                                    x <= x - 1;
                                    y <= y + 2;
                                    can_rot := true;
                                -- (2, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 4 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1) <= '1';
                                    fall_board(x + 3)(y - 1) <= '1';
                                    fall_board(x + 4)(y - 1) <= '1';
                                    x <= x + 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                            when 3 =>
                                -- (0, 0)
                                if game_board_buffer(x + 3)(y - 1 to y + 2 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y + 2) <= (others => '1');
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x + 3)(y + 3 to y + 3 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y to y + 3) <= (others => '1');
                                    can_rot := true;
                                    y <= y + 1;
                                -- (0, -2)
                                elsif game_board_buffer(x + 3)(y - 3 + 3 to y + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 3 to y) <= (others => '1');
                                    y <= y - 2;
                                    can_rot := true;
                                -- (2, 1)
                                elsif game_board_buffer(x + 2 + 3)(y to y + 3 + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 2)(y to y + 3) <= (others => '1');
                                    x <= x + 2;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-1, -2)
                                elsif game_board_buffer(x - 1 + 3)(y - 3 + 3 to y + 3) = "0000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 3 to y) <= (others => '1');
                                    x <= x - 1;
                                    y <= y - 2;
                                    can_rot := true;
                                end if;
                        end case;
                    when "010" => 
                        case rot is
                            when 0 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y to y + 1) <= "11";
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1 to y) <= "11";
                                    fall_board(x)(y - 1) <= '1';
                                    fall_board(x + 1)(y - 1) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 to y + 3) = "00" and game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y) <= "11";
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1) <= '1';
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y to y + 1) <= "11";
                                    fall_board(x + 2)(y) <= '1';
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1 to y) <= "11";
                                    fall_board(x + 2)(y - 1) <= '1';
                                    fall_board(x + 3)(y - 1) <= '1';
                                    x <= x + 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                            when 1 =>
                                -- (0, 0)
                                if game_board_buffer(x)(y - 1 + 3 to y + 1 + 3) = "111" and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '1' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x + 1)(y + 1) <= '1';
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x + 3)(y + 3 to y + 2 + 3) = "111" and game_board_buffer(x + 1 + 3)(y + 2 + 3) = '1' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y to y + 2) <= (others => '1');
                                    fall_board(x + 1)(y + 2) <= '1';
                                    y <= y + 1;
                                    can_rot := true;
                                -- (1, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 3 to y + 2 + 3) = "111" and game_board_buffer(x + 2 + 3)(y + 2 + 3) = '1' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y to y + 2) <= (others => '1');
                                    fall_board(x + 2)(y + 2) <= '1';
                                    x <= x + 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "111" and game_board_buffer(x - 1 + 3)(y + 1 + 3) = '1' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x - 1)(y + 1) <= '1';
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, 1)
                                elsif game_board_buffer(x - 2 + 3)(y to y + 2 + 3) = "111" and game_board_buffer(x - 1 + 3)(y + 2 + 3) = '1' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y to y + 2) <= (others => '1');
                                    fall_board(x - 1)(y + 2) <= '1';
                                    x <= x - 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y - 1 to y) <= "11";
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y + 1) <= '1';
                                    fall_board(x + 1)(y to y + 1) <= "11";
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-1, 1)
                                elsif game_board_buffer(x - 2 + 3)(y + 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y + 1) <= '1';
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y to y + 1) <= "11";
                                    x <= x - 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y) <= '1';
                                    fall_board(x + 3)(y - 1 to y) <= "11";
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y + 1) <= '1';
                                    fall_board(x + 2)(y + 1) <= '1';
                                    fall_board(x + 3)(y to y + 1) <= "11";
                                    x <= x + 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 3 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1 to y + 1) <= "111";
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 3)(y - 2 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 2) <= '1';
                                    fall_board(x)(y - 2 to y) <= "111";
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, -1)
                                elsif game_board_buffer(x + 3)(y - 2 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 2) <= '1';
                                    fall_board(x + 1)(y - 2 to y) <= "111";
                                    x <= x + 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 3 + 3)(y - 1 + 3) = '0' and game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y - 1) <= '1';
                                    fall_board(x - 2)(y - 1 to y + 1) <= "111";
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 3 + 3)(y - 2 + 3) = '0' and game_board_buffer(x - 2 + 3)(y - 2 + 3 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y - 2) <= '1';
                                    fall_board(x - 2)(y - 2 to y) <= "111";
                                    x <= x - 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                        end case;
                    when "011" =>
                        case rot is
                            when 0 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y to y + 1) <= "11";
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1) <= '1';
                                    fall_board(x + 1)(y - 1 to y) <= "11";
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1) <= '1';
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1 to y) <= "11";
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3 + 3)(y to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y) <= '1';
                                    fall_board(x + 3)(y to y + 1) <= "11";
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1) <= '1';
                                    fall_board(x + 3)(y - 1 to y) <= "11";
                                    x <= x + 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                            when 1 =>
                                -- (0, 0)
                                if game_board_buffer(x + 3)(y - 1 + 3 to y + 1 + 3) = "000" and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x + 1)(y - 1) <= '1';
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x + 3)(y + 3 to y + 2 + 3) = "000" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y to y + 2) <= (others => '1');
                                    fall_board(x + 1)(y) <= '1';
                                    y <= y + 1;
                                    can_rot := true;
                                -- (1, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 3 to y + 2 + 3) = "000" and game_board_buffer(x + 2 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y to y + 2) <= (others => '1');
                                    fall_board(x + 2)(y) <= '1';
                                    x <= x + 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "000" and game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x - 1)(y - 1) <= '1';
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, 1)
                                elsif game_board_buffer(x - 2 + 3)(y + 3 to y + 2 + 3) = "000" and game_board_buffer(x - 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y to y + 2) <= (others => '1');
                                    fall_board(x - 1)(y) <= '1';
                                    x <= x - 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1 to y) <= "11";
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x - 1 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y to y + 1) <= "11";
                                    fall_board(x)(y + 1) <= '1';
                                    fall_board(x + 1)(y + 1) <= '1';
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-1, 1)
                                elsif game_board_buffer(x - 2 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y to y + 1) <= "11";
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y + 1) <= '1';
                                    x <= x - 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1 to y) <= "11";
                                    fall_board(x + 2)(y) <= '1';
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y to y + 1) <= "11";
                                    fall_board(x + 2)(y + 1) <= '1';
                                    fall_board(x + 3)(y + 1) <= '1';
                                    x <= x + 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 3 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y - 1 to y + 1) <= "111";
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 2 + 3 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y - 2 to y) <= "111";
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, -1)
                                elsif game_board_buffer(x + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 2 + 3 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y) <= '1';
                                    fall_board(x + 1)(y - 2 to y) <= "111";
                                    x <= x + 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 3 + 3)(y + 1 + 3) = '0' and game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y + 1) <= '1';
                                    fall_board(x - 2)(y - 1 to y + 1) <= "111";
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 3 + 3)(y + 3) = '0' and game_board_buffer(x - 2 + 3)(y - 2 + 3 to y + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y) <= '1';
                                    fall_board(x - 2)(y - 2 to y) <= "111";
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                        end case;
                    when "100" =>
                        case rot is
                            when 0 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y - 1 to y) <= "11";
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y - 1 to y) <= "11";
                                    fall_board(x + 1)(y) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y) <= '1';
                                    fall_board(x - 1)(y - 1 to y) <= "11";
                                    fall_board(x)(y) <= '1';
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y - 1 to y) <= "11";
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x + 3 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 2 to y - 1) <= "11";
                                    fall_board(x + 3)(y - 1) <= '1';
                                    x <= x + 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                            when 1 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 3 to y + 2 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y to y + 2) <= (others => '1');
                                    y <= y + 1;
                                    can_rot := true;
                                -- (1, 1)
                                elsif game_board_buffer(x + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 3 to y + 2 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y + 1) <= '1';
                                    fall_board(x + 1)(y to y + 2) <= (others => '1');
                                    x <= x + 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 3 + 3)(y + 3) = '0' and game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y) <= '1';
                                    fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, 1)
                                elsif game_board_buffer(x - 3 + 3)(y + 1 + 3) = '0' and game_board_buffer(x - 2 + 3)(y + 3 to y + 2 + 3) = "000" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 3)(y + 1) <= '1';
                                    fall_board(x - 2)(y to y + 2) <= (others => '1');
                                    x <= x - 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y to y + 1) <= "11";
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, 1)
                                elsif game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3 to y + 2 + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y + 1 to y + 2) <= "11";
                                    fall_board(x + 1)(y + 1) <= '1';
                                    y <= y + 1;
                                    can_rot := true;
                                -- (-1, 1)
                                elsif game_board_buffer(x - 2 + 3)(y + 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y + 1 + 3 to y + 2 + 3) = "00" and game_board_buffer(x + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y + 1) <= '1';
                                    fall_board(x - 1)(y + 1 to y + 2) <= "11";
                                    fall_board(x)(y + 1) <= '1';
                                    x <= x - 1;
                                    y <= y + 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y to y + 1 + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y to y + 1) <= "11";
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3 to y + 2 + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y + 1) <= '1';
                                    fall_board(x + 2)(y + 1 to y + 2) <= "11";
                                    fall_board(x + 3)(y + 1) <= '1';
                                    x <= x + 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 3 =>
                                -- (0, 0)
                                if game_board_buffer(x + 3)(y - 1 + 3 to y + 1 + 3) = "000" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x + 3)(y - 2 + 3 to y + 3) = "000" and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 2 to y) <= (others => '1');
                                    fall_board(x + 1)(y - 1) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 2 + 3 to y + 3) = "000" and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 2 to y) <= (others => '1');
                                    fall_board(x + 2)(y - 1) <= '1';
                                    x <= x + 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 1 + 3) = "000" and game_board_buffer(x - 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                    fall_board(x - 1)(y) <= '1';
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 2 + 3 to y + 3) = "000" and game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 2 to y) <= (others => '1');
                                    fall_board(x - 1)(y - 1) <= '1';
                                    x <= x - 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                        end case;
                    when "101" =>
                    when "110" =>
                        case rot is
                            when 0 | 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y + 1) <= '1';
                                    fall_board(x)(y to y + 1) <= "11";
                                    fall_board(x + 1)(y) <= '1';
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y - 1 to y) <= "11";
                                    fall_board(x + 1)(y - 1) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, -1)
                                elsif game_board_buffer(x - 2 + 3)(y + 3) = '0' and game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3)(y - 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y) <= '1';
                                    fall_board(x - 1)(y - 1 to y) <= "11";
                                    fall_board(x)(y - 1) <= '1';
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y + 1) <= '1';
                                    fall_board(x + 2)(y to y + 1) <= "11";
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, 1)
                                elsif game_board_buffer(x + 1 + 3)(y + 2 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3 to y + 2 + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y + 2) <= '1';
                                    fall_board(x + 2)(y + 1 to y + 2) <= "11";
                                    fall_board(x + 3)(y + 1) <= '1';
                                    x <= x + 2;
                                    y <= y + 1;
                                    can_rot := true;
                                end if;
                            when 1 | 3 =>
                                -- (0, 0)
                                if game_board_buffer(x + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y) <= "00";
                                    fall_board(x + 1)(y to y + 1) <= "00";
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 2 to y - 1) <= "00";
                                    fall_board(x + 1)(y - 1 to y) <= "00";
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 2 to y - 1) <= "00";
                                    fall_board(x + 2)(y - 1 to y) <= "00";
                                    x <= x + 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x - 1 + 3)(y + 3 to y + 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y) <= "00";
                                    fall_board(x - 1)(y to y + 1) <= "00";
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 2 + 3 to y - 1 + 3) = "00" and game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 2 to y - 1) <= "00";
                                    fall_board(x - 1)(y - 1 to y) <= "00";
                                    x <= x - 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                        end case;
                    when "111" =>
                        case rot is
                            when 0 | 2 =>
                                -- (0, 0)
                                if game_board_buffer(x - 1 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y) <= '1';
                                    fall_board(x)(y to y + 1) <= (others => '1');
                                    fall_board(x + 1)(y + 1) <= '1';
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x - 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 1)(y - 1) <= '1';
                                    fall_board(x)(y - 1 to y) <= (others => '1');
                                    fall_board(x + 1)(y) <= '1';
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-1, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3) = '0' and game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1) <= '1';
                                    fall_board(x - 1)(y - 1 to y) <= (others => '1');
                                    fall_board(x)(y) <= '1';
                                    x <= x - 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (2, 0)
                                elsif game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 1 + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y) <= '1';
                                    fall_board(x + 2)(y to y + 1) <= (others => '1');
                                    fall_board(x + 3)(y + 1) <= '1';
                                    x <= x + 2;
                                    can_rot := true;
                                -- (2, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1) <= '1';
                                    fall_board(x + 2)(y - 1 to y) <= (others => '1');
                                    fall_board(x + 3)(y) <= '1';
                                    x <= x + 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                            when 1 | 3 =>
                                -- (0, 0)
                                if game_board_buffer(x + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y to y + 1) <= (others => '1');
                                    fall_board(X + 1)(y - 1 to y) <= (others => '1');
                                    can_rot := true;
                                -- (0, -1)
                                elsif game_board_buffer(x + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 2 + 3 to y - 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x)(y - 1 to y) <= (others => '1');
                                    fall_board(X + 1)(y - 2 to y - 1) <= (others => '1');
                                    y <= y - 1;
                                    can_rot := true;
                                -- (1, -1)
                                elsif game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 2 + 3)(y - 2 + 3 to y - 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x + 1)(y - 1 to y) <= (others => '1');
                                    fall_board(X + 2)(y - 2 to y - 1) <= (others => '1');
                                    x <= x + 1;
                                    y <= y - 1;
                                    can_rot := true;
                                -- (-2, 0)
                                elsif game_board_buffer(x - 2 + 3)(y to y + 1 + 3) = "00" and game_board_buffer(x - 1 + 3)(y - 1 + 3 to y + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y to y + 1) <= (others => '1');
                                    fall_board(X - 1)(y - 1 to y ) <= (others => '1');
                                    x <= x - 2;
                                    can_rot := true;
                                -- (-2, -1)
                                elsif game_board_buffer(x - 2 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x - 1 + 3)(y - 2 + 3 to y - 1 + 3) = "00" then
                                    fall_board <= (others => (others => '0'));
                                    fall_board(x - 2)(y - 1 to y) <= (others => '1');
                                    fall_board(X - 1)(y - 2 to y - 1) <= (others => '1');
                                    x <= x - 2;
                                    y <= y - 1;
                                    can_rot := true;
                                end if;
                        end case;
                    when others =>
                end case;
                
                -- if can_rot was true, update the rotation number of the block
                if can_rot then
                    rot <= (rot + 1) mod 4;
                end if;
            end if;
        end if;
    end if;
    
    -- if game_clk_sync is rising
    if rising_edge(clk) and game_clk_sync = "01" then
        -- if new_fall signal is 1, initialize fall_board based on the block type
        if new_fall_sync = "01" then
            fall_board <= (others => (others => '0'));
            rot <= 0;
            case block_type is
                when "001" =>
                    fall_board(xstart)(ystart - 1 to ystart + 2) <= (others => '1');
                    x <= xstart;
                    y <= ystart;
                when "010" => 
                    fall_board(xstart)(ystart - 1) <= '1';
                    fall_board(xstart + 1)(ystart - 1 to ystart + 1) <= (others => '1');
                    x <= xstart + 1;
                    y <= ystart;
                when "011" =>
                    fall_board(xstart)(ystart + 1) <= '1';
                    fall_board(xstart + 1)(ystart - 1 to ystart + 1) <= (others => '1');
                    x <= xstart + 1;
                    y <= ystart;
                when "100" =>
                    fall_board(xstart)(ystart - 1 to ystart + 1) <= (others => '1');
                    fall_board(xstart + 1)(ystart) <= '1';
                    x <= xstart;
                    y <= ystart;
                when "101" =>
                    fall_board(xstart)(ystart to ystart + 1) <= (others => '1');
                    fall_board(xstart + 1)(ystart to ystart + 1) <= (others => '1');
                    x <= xstart;
                    y <= ystart;
                when "110" =>
                    fall_board(xstart)(ystart - 1 to ystart) <= (others => '1');
                    fall_board(xstart + 1)(ystart to ystart + 1) <= (others => '1');
                    x <= xstart;
                    y <= ystart;
                when "111" =>
                    fall_board(xstart)(ystart to ystart + 1) <= (others => '1');
                    fall_board(xstart + 1)(ystart - 1 to ystart + 1) <= (others => '1');
                    x <= xstart;
                    y <= ystart;
                when others =>
            end case;
        else
            -- each game clock, the block falls one square or is placed
            can_fall := false;
            case block_type is
                when "001" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 2 + 3) = "0000" then
                                can_fall := true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x + 3 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 2 + 3) = "0000" then
                                can_fall := true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x + 3 + 3)(y + 3) = '0' then
                                can_fall := true;
                            end if;
                    end case;
                when "010" => 
                    case rot is
                        when 0 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                can_fall := true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 3) = "00" then
                                can_fall := true;
                            end if;
                    end case;
                when "011" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                can_fall := true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x + 2 + 3)(y + 3 to y + 1 + 3) = "00" then
                                can_fall := true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 2 + 3)(y - 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 3)(y - 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                    end case;
                when "100" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                report "falling, " & std_logic'image(game_board_buffer(x + 2 + 3)(y + 3)) & " should be 0";
                                can_fall := true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 1 + 3)(y - 1 + 3 to y + 1 + 3) = "000" then
                                can_fall := true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                    end case;
                when "101" =>
                    if game_board_buffer(x + 1 + 3)(y + 3 to y + 1 + 3) = "00" then
                        can_fall := true;
                    end if;
                when "110" =>
                    case rot is
                        when 0 | 2 =>
                            if game_board_buffer(x + 2 + 3)(y + 3 to y + 1 + 3) = "00" and game_board_buffer(x + 1 + 3)(y - 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 1 | 3 =>
                            if game_board_buffer(x + 2 + 3)(y + 3) = '0' and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                    end case;
                when "111" =>
                    case rot is
                        when 0 | 2 =>
                            if game_board_buffer(x + 2 + 3)(y - 1 + 3 to y + 3) = "00" and game_board_buffer(x + 1 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                        when 1 | 3 =>
                            if game_board_buffer(x + 1 + 3)(y + 3) = '0' and game_board_buffer(x + 2 + 3)(y + 1 + 3) = '0' then
                                can_fall := true;
                            end if;
                    end case;
                when others =>
            end case;
            
            if can_fall then
                x <= x + 1;
                fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                done_fall <= '0';
            else
                done_fall <= '1';
            end if;
        end if;
    end if;
end process;

-- process to synchronize the inputs
process(clk)
begin
    if rising_edge(clk) then
        game_clk_sync <= game_clk_sync(0) & game_clk;
        left_sync <= left_sync(0) & left;
        right_sync <= right_sync(0) & right;
        up_sync <= up_sync(0) & up;
        place_sync <= place_sync(0) & place;
    end if;
end process;

process(game_clk)
begin
    if rising_edge(game_clk) then
        new_fall_sync <= new_fall_sync(0) & new_fall;
    end if;
end process;

end Behavioral;
