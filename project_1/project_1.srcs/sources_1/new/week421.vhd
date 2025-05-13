library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

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
        Port ( 
            generate_block : in STD_LOGIC;
            next_block : buffer STD_LOGIC_VECTOR(2 downto 0);
            clk : in STD_LOGIC
        );
    end component;
    
    component line_clear is
        Port (
            clear_board         :   in std_logic;
            game_board          :   in boardSize;
            game_board_cleared  :   buffer boardSize;
            clk                 :   in std_logic;
            hundreds : out STD_LOGIC_VECTOR (6 downto 0);
            tens     : out STD_LOGIC_VECTOR (6 downto 0);
            ones     : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
    
    component block_memory is
        Port (
            place           :   in std_logic;
            clk             :   in std_logic;
            fall_board      :   in boardSize;
            game_board      :   in boardSize;
            combined_board  :   out boardSize
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
            finished        :   out std_logic;
            game_board      :   in boardSize;
            fall_board      :   buffer boardSize
        );
    end component;

    signal game_board : boardSize := (18 => (others => '1'), others => (others => '0'));
    signal fall_board : boardSize;
    signal combined_board : boardSize;
    signal game_board_cleared : boardSize := (others => (others => '0'));
    signal output_state : states;
    signal gen_block_en : std_logic := '0';
    signal done_gen : std_logic := '0';
    signal done_fall : std_logic;
    signal done_place : std_logic;
    signal done_score : std_logic;
    signal falling : boolean;
    signal new_fall : std_logic;
    signal finished : std_logic;
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
                                    
    BlockGenerator : block_generator port map ( generate_block => gen_block_en,
                                                next_block => next_block,
                                                clk => clk);

    LineClear : line_clear port map (   clear_board => done_place,
                                        game_board => game_board,
                                        game_board_cleared => game_board_cleared,
                                        clk => clk,
                                        hundreds => hundreds,
                                        tens => tens,
                                        ones => ones);
                                        
    BlockMemory : block_memory port map (   place => done_fall,
                                            clk => clk,
                                            fall_board => fall_board,
                                            game_board => game_board,
                                            combined_board => combined_board);
    
    GameControlFSM : game_control_FSM port map (    start_game => start_game,
                                                    done_gen => done_gen,
                                                    done_fall => done_fall,
                                                    done_place => done_place,
                                                    done_score => done_score,
                                                    game_clk => game_clk,
                                                    clk => clk,
                                                    output_state => output_state);
                                                    
    FallingBlock : falling_block port map ( block_type => next_block,
                                            new_fall => new_fall,
                                            clk => clk,
                                            game_clk => game_clk,
                                            left => left,
                                            right => right,
                                            up => up,
                                            place => place,
                                            finished => finished,
                                            game_board => game_board,
                                            fall_board => fall_board);
                                            
    process (clk)
    begin
        if rising_edge(game_clk) then
            case output_state is
                when init =>
                when gen_block =>
                    gen_block_en <= '1';
                    curr_block <= next_block;
                    done_gen <= '1';
                    falling <= false;
                when fall_block =>
                    if not falling then
                        new_fall <= '1';
                        falling <= true;
                    else
                        new_fall <= '0';
                    end if;
                when place_block =>
                when scoring =>
            end case;
        end if;
    end process;
end Structural;
