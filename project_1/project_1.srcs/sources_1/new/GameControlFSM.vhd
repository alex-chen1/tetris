library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utilities.all;

entity game_control_FSM is
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
end game_control_FSM;

architecture Behavioral of game_control_FSM is
    signal curr_state : states := init;
    signal start_game_vector : std_logic_vector(1 downto 0);
    signal done_gen_vector : std_logic_vector(1 downto 0);
    signal done_fall_vector : std_logic_vector(1 downto 0);
    signal done_place_vector : std_logic_vector(1 downto 0);
    signal done_score_vector : std_logic_vector(1 downto 0);
    
    signal game_rise : std_logic;
    signal gen_rise : std_logic;
    signal fall_rise : std_logic;
    signal place_rise : std_logic;
    signal score_rise : std_logic;
    
begin

    output_state <= curr_state;
    

process(game_clk)
begin
    if rising_edge(game_clk) then
        case curr_state is
            when init =>
                if game_rise = '1' then
                    curr_state <= gen_block;
                end if;
            when gen_block =>
                if gen_rise = '1' then
                    curr_state <= fall_block;
                end if;
            when fall_block =>
                if fall_rise = '1' then
                    curr_state <= place_block;
                end if;
            when place_block =>
                if place_rise = '1' then
                    curr_state <= scoring;
                end if;
            when scoring =>
                if score_rise = '1' then
                    curr_state <= gen_block;
                end if;
        end case;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        start_game_vector <= start_game_vector(0) & start_game;
        done_gen_vector <= done_gen_vector(0) & done_gen;
        done_fall_vector <= done_fall_vector(0) & done_fall;
        done_place_vector <= done_place_vector(0) & done_place;
        done_score_vector <= done_score_vector(0) & done_score;
        
        if start_game_vector = "01" then
            game_rise <= '1';
        end if;
        if done_gen_vector = "01" then
            gen_rise <= '1';
        end if;
        if done_fall_vector = "01" then
            fall_rise <= '1';
        end if;
        if done_place_vector = "01" then
            place_rise <= '1';
        end if;
        if done_score_vector = "01" then
            score_rise <= '1';
        end if;
        
        case curr_state is
            when init =>
            when gen_block =>
                game_rise <= '0';
                score_rise <= '0';
            when fall_block =>
                gen_rise <= '0';
            when place_block =>
                fall_rise <= '0';
            when scoring =>
                place_rise <= '0';
        end case;
        
    end if;
end process;

end Behavioral;
