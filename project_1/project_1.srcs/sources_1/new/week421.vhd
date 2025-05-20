library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;
-- WIP:
-- handle losses
-- speed up game with down press
-- speed up game with score
-- reset
-- remove vy in falling_block
-- rotation doesn't instantly update x, y, need to make them variables
-- weird things when up triggers with game_clk
entity week421 is
    Port ( nReset               :   in std_logic;
           start_game           :   in std_logic;
           left                 :   in std_logic;
           right                :   in std_logic;
           up                   :   in std_logic;
           place                :   in std_logic;
           r                    :   in std_logic_vector(8 downto 0);
           c                    :   in std_logic_vector(9 downto 0);
           clk                  :   in std_logic;
           game_clk             :   in std_logic;
           hundreds             :   inout STD_LOGIC_VECTOR (6 downto 0);
           tens                 :   inout STD_LOGIC_VECTOR (6 downto 0);
           ones                 :   inout STD_LOGIC_VECTOR (6 downto 0);
           vga_output           :   out std_logic
     );
end week421;

architecture Structural of week421 is    
    component board
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
    end component;
    
    component block_generator
        Port (  generate_block : in STD_LOGIC;
                curr_block : out STD_LOGIC_VECTOR(2 downto 0);
                next_block : buffer STD_LOGIC_VECTOR(2 downto 0);
                done_gen : out std_logic;
                clk : in STD_LOGIC
        );
    end component;
    
    component line_clear is
        Port (
            start_score         :   in std_logic;                       -- signal to clear the lines on the board
            game_board          :   in boardSize;                       -- current game board
            game_board_cleared  :   buffer boardSize;                   -- game board after clearing the lines
            clk                 :   in std_logic;                       -- 8 MHz clock signal
            hundreds            :   out STD_LOGIC_VECTOR (6 downto 0);  -- hundreds digit 7 segment signal
            tens                :   out STD_LOGIC_VECTOR (6 downto 0);  -- tens digit 7 segment signal
            ones                :   out STD_LOGIC_VECTOR (6 downto 0);  -- ones digit 7 segment signal
            done_score          :   out std_logic
        );
    end component;
    
    component block_memory is
        Port (
            start_place     :   in std_logic;
            clk             :   in std_logic;
            fall_board      :   in boardSize;
            game_board      :   in boardSize;
            combined_board  :   out boardSize;
            done_place      :   out std_logic
        );
    end component;
    
    component game_control_FSM is
        Port (
            start_game      :   in std_logic;
            done_gen        :   in std_logic;
            done_fall       :   in std_logic;
            done_place      :   in std_logic;
            done_score      :   in std_logic;
            game_clk        :   in std_logic;
            clk             :   in std_logic;
            output_state    :   out states
        );
    end component;
    
    component falling_block is
        Port (
            block_type      :   in std_logic_vector(2 downto 0);
            new_fall        :   in std_logic;
            clk             :   in std_logic;
            game_clk        :   in std_logic;
            left            :   in std_logic;
            right           :   in std_logic;
            up              :   in std_logic;
            place           :   in std_logic;
            done_fall        :   out std_logic;
            game_board      :   in boardSize;
            fall_board      :   buffer boardSize
        );
    end component;

    signal game_board : boardSize := (others => (others => '0'));
    signal fall_board : boardSize;
    signal combined_board : boardSize;
    signal game_board_cleared : boardSize := (others => (others => '0'));
    
    signal output_state : states;
    
    signal start_gen : std_logic := '0';
    signal done_gen : std_logic := '0';
    signal start_fall : std_logic := '0';
    signal done_fall : std_logic := '0';
    signal start_place : std_logic := '0';
    signal done_place : std_logic := '0';
    signal start_score : std_logic := '0';
    signal done_score : std_logic := '0';
    
    signal next_block : std_logic_vector(2 downto 0) := "000";
    signal curr_block : std_logic_vector(2 downto 0) := "000";
    
begin
    
--    GameBoard : board port map (    nReset => nReset,
--                                    r => r,
--                                    c => c,
--                                    block_type => next_block,
--                                    clk => clk,
--                                    hundreds => hundreds,
--                                    tens => tens,
--                                    ones => ones,
--                                    game_board => game_board,
--                                    vga_output => vga_output);
                                    
    BlockGenerator : block_generator port map ( generate_block => start_gen,
                                                curr_block => curr_block,
                                                next_block => next_block,
                                                done_gen => done_gen,
                                                clk => clk);

    LineClear : line_clear port map (   start_score => start_score,
                                        game_board => combined_board,
                                        game_board_cleared => game_board_cleared,
                                        clk => clk,
                                        hundreds => hundreds,
                                        tens => tens,
                                        ones => ones,
                                        done_score => done_score);
                                        
    BlockMemory : block_memory port map (   start_place => start_place,
                                            clk => clk,
                                            fall_board => fall_board,
                                            game_board => game_board,
                                            combined_board => combined_board,
                                            done_place => done_place);
    
    GameControlFSM : game_control_FSM port map (    start_game => start_game,
                                                    done_gen => done_gen,
                                                    done_fall => done_fall,
                                                    done_place => done_place,
                                                    done_score => done_score,
                                                    game_clk => game_clk,
                                                    clk => clk,
                                                    output_state => output_state);
                                                    
    FallingBlock : falling_block port map ( block_type => curr_block,
                                            new_fall => start_fall,
                                            clk => clk,
                                            game_clk => game_clk,
                                            left => left,
                                            right => right,
                                            up => up,
                                            place => place,
                                            done_fall => done_fall,
                                            game_board => game_board,
                                            fall_board => fall_board);
                                            
    -- enable components
    process (clk)
    begin
        case output_state is
            when init =>
            when gen_block =>
                game_board <= game_board_cleared;
                start_gen <= '1';
                start_fall <= '1';      -- start_fall signal is one game clk earlier so that it will rise with fall_block
            when fall_block =>
                start_place <= '0';
            when place_block =>
                start_place <= '1';
                start_score <= '0';
            when scoring =>
                start_score <= '1';
                start_gen <= '0';
                start_fall <= '0';
        end case;
    end process;
end Structural;
