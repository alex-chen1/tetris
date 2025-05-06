library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package utilities is
    -- define parameters
    constant screen_x               :   integer := 640;
    constant screen_y               :   integer := 480;
    constant rows                   :   integer := 20;
    constant cols                   :   integer := 10;
    constant block_size             :   integer := 18;
    constant space                  :   integer := 2;
    constant rots                   :   integer := 4;
    constant hud_width              :   integer := 160;
    constant hud_div_height         :   integer := 260;
    constant new_block_x_offset     :   integer := 50;
    constant new_block_y_offset     :   integer := 120;
    constant tetrominoes_size       :   integer := 4;
    
    -- define custom data type based on the dimensions of the monitor
    type monitorSize is array(0 to screen_y - 1) of std_logic_vector(0 to screen_x - 1);
    type boardSize is array(0 to rows - 1) of std_logic_vector(0 to cols - 1);
    type boardWBufferSize is array(0 to rows + 5) of std_logic_vector(0 to cols + 5);
    type newBlockSize is array(0 to tetrominoes_size - 1) of std_logic_vector(0 to tetrominoes_size - 1);
    
    -- defines states for game control FSM
    type states is (
        init,
        gen_block,
        fall_block,
        place_block,
        scoring);
end package;
