library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- need to draw fall board borders, draw walls and floor of 1
entity falling_block is
    Port (
        block_type      :   in std_logic_vector(2 downto 0);
        new_fall        :   in std_logic;
        clk             :   in std_logic;
        game_clk        :   in std_logic;
        left            :   in std_logic;
        right           :   in std_logic;
        up              :   in std_logic;
        place           :   in std_logic;
        finished        :   out std_logic;
        game_board      :   inout boardSize;
        fall_board      :   inout boardSize
    );
end falling_block;

architecture Behavioral of falling_block is

constant xstart : integer := 0;
constant ystart : integer := cols / 2 - 1;
signal x : integer range 0 to rows - 1;
signal y : integer range 0 to cols - 1;
signal rot : integer range 0 to 3;
signal can_left : boolean;
signal can_right : boolean;
signal can_rot : boolean;
signal game_board_buffer : boardWBufferSize := (others => (others => '1'));

begin

GameBoardMap : for i in 0 to rows - 1 generate
    game_board_buffer(i)(0 to cols - 1) <= game_board(i);
end generate GameBoardMap;

process(clk)
begin
    if rising_edge(clk) then
        if rising_edge(new_fall) then
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
            end case;
        end if;
        
        if rising_edge(place) then
            case block_type is
                when "001" =>
                    while game_board_buffer(x + 1)(y - 1 to y + 2) = "0000" loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "010" => 
                    while game_board_buffer(x + 1)(y - 1 to y + 1) = "000" loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "011" =>
                    while game_board_buffer(x + 1)(y - 1 to y + 1) = "000" loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "100" =>
                    while game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 1)(y + 1) = '0' loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "101" =>
                    while game_board_buffer(x + 1)(y to y + 1) = "00" loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "110" =>
                    while game_board_buffer(x + 2)(y to y + 1) = "00" and game_board_buffer(x + 1)(y - 1) = '0' loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
                when "111" =>
                    while game_board_buffer(x + 2)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y + 1) = '0' loop
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    end loop;
            end case;
        else
            if rising_edge(left) then
                -- check for collision, then shift left
                can_left <= false;
                case block_type is
                when "001" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x)(y) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x)(y + 2) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x - 1)(y + 2) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                when "010" => 
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x - 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                when "011" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x - 1)(y) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y - 2) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                when "100" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                when "101" =>
                    if game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                        can_left <= true;
                    end if;
                when "110" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                when "111" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                can_left <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 2) = '0' then
                                can_left <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                can_left <= true;
                            end if;
                    end case;
                end case;
                
                if can_left then
                    y <= y - 1;
                    for i in 0 to rows - 1 loop
                        fall_board(i) <= fall_board(i)(1 to cols - 1) & fall_board(i)(0);
                    end loop;
                end if;
                
            elsif rising_edge(right) then
                -- check for collision, then shift right
                case block_type is
                when "001" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y + 3) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' and game_board_buffer(x + 2)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x + 1)(y + 3) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' and game_board_buffer(x + 2)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                when "010" => 
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x - 1)(y) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                when "011" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                when "100" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                when "101" =>
                    if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                        can_right <= true;
                    end if;
                when "110" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                when "111" =>
                    case rot is
                        when 0 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 1 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                        when 2 =>
                            if game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                can_right <= true;
                            end if;
                        when 3 =>
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                can_right <= true;
                            end if;
                    end case;
                end case;
                
                if can_right then
                    y <= y + 1;
                    for i in 0 to rows - 1 loop
                        fall_board(i) <= fall_board(i)(0 to cols - 2) & fall_board(i)(cols - 1);
                    end loop;
                end if;
            end if;
            
            if rising_edge(up) then
                -- check for collision, then rotate
                can_rot <= false;
                case block_type is
                when "001" =>
                    case rot is
                        when 0 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' and game_board_buffer(x + 2)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y + 1) <= '1';
                                fall_board(x + 1)(y + 1) <= '1';
                                fall_board(x + 2)(y + 1) <= '1';
                                can_rot <= true;
                            -- (0, -2)
                            elsif game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1) <= '1';
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1) <= '1';
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' and game_board_buffer(x + 2)(y + 2) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 2) <= '1';
                                fall_board(x)(y + 2) <= '1';
                                fall_board(x + 1)(y + 2) <= '1';
                                fall_board(x + 2)(y + 2) <= '1';
                                can_rot <= true;
                            -- (1, -2)
                            elsif game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1) = '0' and game_board_buffer(x + 3)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1) <= '1';
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1) <= '1';
                                fall_board(x + 3)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-2, 1)
                            elsif game_board_buffer(x - 3)(y + 2) = '0' and game_board_buffer(x - 2)(y + 2) = '0' and game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y + 2) <= '1';
                                fall_board(x - 2)(y + 2) <= '1';
                                fall_board(x - 1)(y + 2) <= '1';
                                fall_board(x)(y + 2) <= '1';
                                can_rot <= true;
                            end if;
                        when 1 =>
                            -- (0, 0)
                            if game_board_buffer(x + 1)(y - 1 to y + 2) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1 to y + 2) <= (others => '1');
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x + 1)(y - 2 to y + 1) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 2 to y + 1) <= (others => '1');
                                can_rot <= true;
                            -- (0, 2)
                            elsif game_board_buffer(x + 1)(y + 1 to y + 4) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y + 1 to y + 4) <= (others => '1');
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 1)(y - 2 to y + 1) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 2 to y + 1) <= (others => '1');
                                can_rot <= true;
                            -- (1, 2)
                            elsif game_board_buffer(x + 2)(y + 1 to y + 4) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 2)(y + 1 to y + 4) <= (others => '1');
                                can_rot <= true;
                            end if;
                        when 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y) <= '1';
                                can_rot <= true;
                            -- (0, 2)
                            elsif game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' and game_board_buffer(x + 2)(y + 2) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 2) <= '1';
                                fall_board(x)(y + 2) <= '1';
                                fall_board(x + 1)(y + 2) <= '1';
                                fall_board(x + 2)(y + 2) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1) <= '1';
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-1, 2)
                            elsif game_board_buffer(x - 2)(y + 2) = '0' and game_board_buffer(x - 1)(y + 2) = '0' and game_board_buffer(x)(y + 2) = '0' and game_board_buffer(x + 1)(y + 2) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y + 2) <= '1';
                                fall_board(x - 1)(y + 2) <= '1';
                                fall_board(x)(y + 2) <= '1';
                                fall_board(x + 1)(y + 2) <= '1';
                                can_rot <= true;
                            -- (2, -1)
                            elsif game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1) = '0' and game_board_buffer(x + 3)(y - 1) = '0' and game_board_buffer(x + 4)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1) <= '1';
                                fall_board(x + 3)(y - 1) <= '1';
                                fall_board(x + 4)(y - 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 3 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y - 1 to y + 2) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y + 2) <= (others => '1');
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x)(y to y + 3) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y to y + 3) <= (others => '1');
                                can_rot <= true;
                            -- (0, -2)
                            elsif game_board_buffer(x)(y - 3 to y) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 3 to y) <= (others => '1');
                                can_rot <= true;
                            -- (2, 1)
                            elsif game_board_buffer(x + 2)(y to y + 3) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 2)(y to y + 3) <= (others => '1');
                                can_rot <= true;
                            -- (-1, -2)
                            elsif game_board_buffer(x - 1)(y - 3 to y) = "0000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 3 to y) <= (others => '1');
                                can_rot <= true;
                            end if;
                    end case;
                when "010" => 
                    case rot is
                        when 0 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y to y + 1) = "00" and game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y to y + 1) <= "11";
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 1 to y) = "00" and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1 to y) <= "11";
                                fall_board(x)(y - 1) <= '1';
                                fall_board(x + 1)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-1, -1)
                            elsif game_board_buffer(x - 2)(y - 1 to y) = "00" and game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y) <= "11";
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y to y + 1) = "00" and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y to y + 1) <= "11";
                                fall_board(x + 2)(y) <= '1';
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            -- (2, -1)
                            elsif game_board_buffer(x + 1)(y - 1 to y) = "00" and game_board_buffer(x + 2)(y - 1) = '0' and game_board_buffer(x + 3)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1 to y) <= "11";
                                fall_board(x + 2)(y - 1) <= '1';
                                fall_board(x + 3)(y - 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 1 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y - 1 to y + 1) = "111" and game_board_buffer(x + 1)(y + 1) = '1' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x + 1)(y + 1) <= '1';
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x)(y to y + 2) = "111" and game_board_buffer(x + 1)(y + 2) = '1' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y to y + 2) <= (others => '1');
                                fall_board(x + 1)(y + 2) <= '1';
                                can_rot <= true;
                            -- (1, 1)
                            elsif game_board_buffer(x + 1)(y to y + 2) = "111" and game_board_buffer(x + 2)(y + 2) = '1' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y to y + 2) <= (others => '1');
                                fall_board(x + 2)(y + 2) <= '1';
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 2)(y - 1 to y + 1) = "111" and game_board_buffer(x - 1)(y + 1) = '1' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x - 1)(y + 1) <= '1';
                                can_rot <= true;
                            -- (-2, 1)
                            elsif game_board_buffer(x - 2)(y to y + 2) = "111" and game_board_buffer(x - 1)(y + 2) = '1' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y to y + 2) <= (others => '1');
                                fall_board(x - 1)(y + 2) <= '1';
                                can_rot <= true;
                            end if;
                        when 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y - 1 to y) <= "11";
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y + 1) <= '1';
                                fall_board(x + 1)(y to y + 1) <= "11";
                                can_rot <= true;
                            -- (-1, 1)
                            elsif game_board_buffer(x - 2)(y + 1) = '0' and game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y + 1) <= '1';
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y to y + 1) <= "11";
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 3)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y) <= '1';
                                fall_board(x + 3)(y - 1 to y) <= "11";
                                can_rot <= true;
                            -- (2, 1)
                            elsif game_board_buffer(x + 1)(y + 1) = '0' and game_board_buffer(x + 2)(y + 1) = '0' and game_board_buffer(x + 3)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y + 1) <= '1';
                                fall_board(x + 2)(y + 1) <= '1';
                                fall_board(x + 3)(y to y + 1) <= "11";
                                can_rot <= true;
                            end if;
                        when 3 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1 to y + 1) <= "111";
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 2) = '0' and game_board_buffer(x)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 2) <= '1';
                                fall_board(x)(y - 2 to y) <= "111";
                                can_rot <= true;
                            -- (1, -1)
                            elsif game_board_buffer(x)(y - 2) = '0' and game_board_buffer(x + 1)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 2) <= '1';
                                fall_board(x + 1)(y - 2 to y) <= "111";
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 3)(y - 1) = '0' and game_board_buffer(x - 2)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y - 1) <= '1';
                                fall_board(x - 2)(y - 1 to y + 1) <= "111";
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 3)(y - 2) = '0' and game_board_buffer(x - 2)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y - 2) <= '1';
                                fall_board(x - 2)(y - 2 to y) <= "111";
                                can_rot <= true;
                            end if;
                    end case;
                when "011" =>
                    case rot is
                        when 0 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y to y + 1) <= "11";
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1) = '0' and game_board_buffer(x + 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1) <= '1';
                                fall_board(x + 1)(y - 1 to y) <= "11";
                                can_rot <= true;
                            -- (-1, -1)
                            elsif game_board_buffer(x - 2)(y - 1) = '0' and game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1) <= '1';
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1 to y) <= "11";
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 3)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y) <= '1';
                                fall_board(x + 3)(y to y + 1) <= "11";
                                can_rot <= true;
                            -- (2, -1)
                            elsif game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1) = '0' and game_board_buffer(x + 3)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1) <= '1';
                                fall_board(x + 3)(y - 1 to y) <= "11";
                                can_rot <= true;
                            end if;
                        when 1 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y - 1 to y + 1) = "000" and game_board_buffer(x + 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x + 1)(y - 1) <= '1';
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x)(y to y + 2) = "000" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y to y + 2) <= (others => '1');
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (1, 1)
                            elsif game_board_buffer(x + 1)(y to y + 2) = "000" and game_board_buffer(x + 2)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y to y + 2) <= (others => '1');
                                fall_board(x + 2)(y) <= '1';
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 2)(y - 1 to y + 1) = "000" and game_board_buffer(x - 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x - 1)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-2, 1)
                            elsif game_board_buffer(x - 2)(y to y + 2) = "000" and game_board_buffer(x - 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y to y + 2) <= (others => '1');
                                fall_board(x - 1)(y) <= '1';
                                can_rot <= true;
                            end if;
                        when 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y - 1 to y) = "00" and game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1 to y) <= "11";
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x - 1)(y to y + 1) = "00" and game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y to y + 1) <= "11";
                                fall_board(x)(y + 1) <= '1';
                                fall_board(x + 1)(y + 1) <= '1';
                                can_rot <= true;
                            -- (-1, 1)
                            elsif game_board_buffer(x - 2)(y to y + 1) = "00" and game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y to y + 1) <= "11";
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y + 1) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y - 1 to y) = "00" and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1 to y) <= "11";
                                fall_board(x + 2)(y) <= '1';
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            -- (2, 1)
                            elsif game_board_buffer(x + 1)(y to y + 1) = "00" and game_board_buffer(x + 2)(y + 1) = '0' and game_board_buffer(x + 3)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y to y + 1) <= "11";
                                fall_board(x + 2)(y + 1) <= '1';
                                fall_board(x + 3)(y + 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 3 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y - 1 to y + 1) <= "111";
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y - 2 to y) <= "111";
                                can_rot <= true;
                            -- (1, -1)
                            elsif game_board_buffer(x)(y) = '0' and game_board_buffer(x + 1)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y) <= '1';
                                fall_board(x + 1)(y - 2 to y) <= "111";
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 3)(y + 1) = '0' and game_board_buffer(x - 2)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y + 1) <= '1';
                                fall_board(x - 2)(y - 1 to y + 1) <= "111";
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 3)(y) = '0' and game_board_buffer(x - 2)(y - 2 to y) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y) <= '1';
                                fall_board(x - 2)(y - 2 to y) <= "111";
                                can_rot <= true;
                            end if;
                    end case;
                when "100" =>
                    case rot is
                        when 0 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y - 1 to y) <= "11";
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 2 to y - 1) = "00" and game_board_buffer(x + 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y - 1 to y) <= "11";
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (-1, -1)
                            elsif game_board_buffer(x - 2)(y - 1) = '0' and game_board_buffer(x - 1)(y - 2 to y - 1) = "00" and game_board_buffer(x)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y) <= '1';
                                fall_board(x - 1)(y - 1 to y) <= "11";
                                fall_board(x)(y) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y - 1 to y) = "00" and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y - 1 to y) <= "11";
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            -- (2, -1)
                            elsif game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 2 to y - 1) = "00" and game_board_buffer(x + 3)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 2 to y - 1) <= "11";
                                fall_board(x + 3)(y - 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 1 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y to y + 2) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y to y + 2) <= (others => '1');
                                can_rot <= true;
                            -- (1, 1)
                            elsif game_board_buffer(x)(y + 1) = '0' and game_board_buffer(x + 1)(y to y + 2) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y + 1) <= '1';
                                fall_board(x + 1)(y to y + 2) <= (others => '1');
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 3)(y) = '0' and game_board_buffer(x - 2)(y - 1 to y + 1) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y) <= '1';
                                fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                can_rot <= true;
                            -- (-2, 1)
                            elsif game_board_buffer(x - 3)(y + 1) = '0' and game_board_buffer(x - 2)(y to y + 2) = "000" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 3)(y + 1) <= '1';
                                fall_board(x - 2)(y to y + 2) <= (others => '1');
                                can_rot <= true;
                            end if;
                        when 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y to y + 1) = "00" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y to y + 1) <= "11";
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, 1)
                            elsif game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y + 1 to y + 2) = "00" and game_board_buffer(x + 1)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y + 1 to y + 2) <= "11";
                                fall_board(x + 1)(y + 1) <= '1';
                                can_rot <= true;
                            -- (-1, 1)
                            elsif game_board_buffer(x - 2)(y + 1) = '0' and game_board_buffer(x - 1)(y + 1 to y + 2) = "00" and game_board_buffer(x)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y + 1) <= '1';
                                fall_board(x - 1)(y + 1 to y + 2) <= "11";
                                fall_board(x)(y + 1) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y to y + 1) = "00" and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y to y + 1) <= "11";
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            -- (2, 1)
                            elsif game_board_buffer(x + 1)(y + 1) = '0' and game_board_buffer(x + 2)(y + 1 to y + 2) = "00" and game_board_buffer(x + 3)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y + 1) <= '1';
                                fall_board(x + 2)(y + 1 to y + 2) <= "11";
                                fall_board(x + 3)(y + 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 3 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y - 1 to y + 1) = "000" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x)(y - 2 to y) = "000" and game_board_buffer(x + 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 2 to y) <= (others => '1');
                                fall_board(x + 1)(y - 1) <= '1';
                                can_rot <= true;
                            -- (1, -1)
                            elsif game_board_buffer(x + 1)(y - 2 to y) = "000" and game_board_buffer(x + 2)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 2 to y) <= (others => '1');
                                fall_board(x + 2)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 2)(y - 1 to y + 1) = "000" and game_board_buffer(x - 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y + 1) <= (others => '1');
                                fall_board(x - 1)(y) <= '1';
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 2)(y - 2 to y) = "000" and game_board_buffer(x - 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 2 to y) <= (others => '1');
                                fall_board(x - 1)(y - 1) <= '1';
                                can_rot <= true;
                            end if;
                    end case;
                when "101" =>
                when "110" =>
                    case rot is
                        when 0 | 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y + 1) = '0' and game_board_buffer(x)(y to y + 1) = "00" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y + 1) <= '1';
                                fall_board(x)(y to y + 1) <= "11";
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y - 1 to y) <= "11";
                                fall_board(x + 1)(y - 1) <= '1';
                                can_rot <= true;
                            -- (-1, -1)
                            elsif game_board_buffer(x - 2)(y) = '0' and game_board_buffer(x - 1)(y - 1 to y) = "00" and game_board_buffer(x)(y - 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y) <= '1';
                                fall_board(x - 1)(y - 1 to y) <= "11";
                                fall_board(x)(y - 1) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y + 1) = '0' and game_board_buffer(x + 2)(y to y + 1) = "00" and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y + 1) <= '1';
                                fall_board(x + 2)(y to y + 1) <= "11";
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            -- (2, 1)
                            elsif game_board_buffer(x + 1)(y + 2) = '0' and game_board_buffer(x + 2)(y + 1 to y + 2) = "00" and game_board_buffer(x + 3)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y + 2) <= '1';
                                fall_board(x + 2)(y + 1 to y + 2) <= "11";
                                fall_board(x + 3)(y + 1) <= '1';
                                can_rot <= true;
                            end if;
                        when 1 | 3 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y) <= "00";
                                fall_board(x + 1)(y to y + 1) <= "00";
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x)(y - 2 to y - 1) = "00" and game_board_buffer(x + 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 2 to y - 1) <= "00";
                                fall_board(x + 1)(y - 1 to y) <= "00";
                                can_rot <= true;
                            -- (1, -1)
                            elsif game_board_buffer(x + 1)(y - 2 to y - 1) = "00" and game_board_buffer(x + 2)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 2 to y - 1) <= "00";
                                fall_board(x + 2)(y - 1 to y) <= "00";
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 2)(y - 1 to y) = "00" and game_board_buffer(x - 1)(y to y + 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y) <= "00";
                                fall_board(x - 1)(y to y + 1) <= "00";
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 2)(y - 2 to y - 1) = "00" and game_board_buffer(x - 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 2 to y - 1) <= "00";
                                fall_board(x - 1)(y - 1 to y) <= "00";
                                can_rot <= true;
                            end if;
                    end case;
                when "111" =>
                    case rot is
                        when 0 | 2 =>
                            -- (0, 0)
                            if game_board_buffer(x - 1)(y) = '0' and game_board_buffer(x)(y to y + 1) = "00" and game_board_buffer(x + 1)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y) <= '1';
                                fall_board(x)(y to y + 1) <= (others => '1');
                                fall_board(x + 1)(y + 1) <= '1';
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x - 1)(y - 1) = '0' and game_board_buffer(x)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 1)(y - 1) <= '1';
                                fall_board(x)(y - 1 to y) <= (others => '1');
                                fall_board(x + 1)(y) <= '1';
                                can_rot <= true;
                            -- (-1, -1)
                            elsif game_board_buffer(x - 2)(y - 1) = '0' and game_board_buffer(x - 1)(y - 1 to y) = "00" and game_board_buffer(x)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1) <= '1';
                                fall_board(x - 1)(y - 1 to y) <= (others => '1');
                                fall_board(x)(y) <= '1';
                                can_rot <= true;
                            -- (2, 0)
                            elsif game_board_buffer(x + 1)(y) = '0' and game_board_buffer(x + 2)(y to y + 1) = "00" and game_board_buffer(x + 3)(y + 1) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y) <= '1';
                                fall_board(x + 2)(y to y + 1) <= (others => '1');
                                fall_board(x + 3)(y + 1) <= '1';
                                can_rot <= true;
                            -- (2, -1)
                            elsif game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y - 1 to y) = "00" and game_board_buffer(x + 3)(y) = '0' then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1) <= '1';
                                fall_board(x + 2)(y - 1 to y) <= (others => '1');
                                fall_board(x + 3)(y) <= '1';
                                can_rot <= true;
                            end if;
                        when 1 | 3 =>
                            -- (0, 0)
                            if game_board_buffer(x)(y to y + 1) = "00" and game_board_buffer(x + 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y to y + 1) <= (others => '1');
                                fall_board(X + 1)(y - 1 to y) <= (others => '1');
                                can_rot <= true;
                            -- (0, -1)
                            elsif game_board_buffer(x)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y - 2 to y - 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x)(y - 1 to y) <= (others => '1');
                                fall_board(X + 1)(y - 2 to y - 1) <= (others => '1');
                                can_rot <= true;
                            -- (1, -1)
                            elsif game_board_buffer(x + 1)(y - 1 to y) = "00" and game_board_buffer(x + 2)(y - 2 to y - 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x + 1)(y - 1 to y) <= (others => '1');
                                fall_board(X + 2)(y - 2 to y - 1) <= (others => '1');
                                can_rot <= true;
                            -- (-2, 0)
                            elsif game_board_buffer(x - 2)(y to y + 1) = "00" and game_board_buffer(x - 1)(y - 1 to y) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y to y + 1) <= (others => '1');
                                fall_board(X - 1)(y - 1 to y ) <= (others => '1');
                                can_rot <= true;
                            -- (-2, -1)
                            elsif game_board_buffer(x - 2)(y - 1 to y) = "00" and game_board_buffer(x - 1)(y - 2 to y - 1) = "00" then
                                fall_board <= (others => (others => '0'));
                                fall_board(x - 2)(y - 1 to y) <= (others => '1');
                                fall_board(X - 1)(y - 2 to y - 1) <= (others => '1');
                                can_rot <= true;
                            end if;
                    end case;
                end case;
                
                if can_rot then
                    rot <= rot + 1;
                end if;
            end if;
        end if;
        
        if rising_edge(game_clk) then
            -- shift down or place block
            case block_type is
                when "001" =>
                    if game_board_buffer(x + 1)(y - 1 to y + 2) = "0000" then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "010" => 
                    if game_board_buffer(x + 1)(y - 1 to y + 1) = "000" then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "011" =>
                    if game_board_buffer(x + 1)(y - 1 to y + 1) = "000" then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "100" =>
                    if game_board_buffer(x + 1)(y - 1) = '0' and game_board_buffer(x + 2)(y) = '0' and game_board_buffer(x + 1)(y + 1) = '0' then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "101" =>
                    if game_board_buffer(x + 1)(y to y + 1) = "00" then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "110" =>
                    if game_board_buffer(x + 2)(y to y + 1) = "00" and game_board_buffer(x + 1)(y - 1) = '0' then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
                when "111" =>
                    if game_board_buffer(x + 2)(y - 1 to y) = "00" and game_board_buffer(x + 1)(y + 1) = '0' then
                        x <= x + 1;
                        fall_board <= fall_board(rows - 1) & fall_board(0 to rows - 2);
                    else
                        finished <= '1';
                    end if;
            end case;
        end if;
    end if;
end process;
end Behavioral;
