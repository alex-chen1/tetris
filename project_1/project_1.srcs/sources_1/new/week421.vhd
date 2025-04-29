----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 11:22:28 PM
-- Design Name: 
-- Module Name: week421 - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity week421 is
    Port ( nReset           :   in std_logic;
           r                :   in std_logic_vector(8 downto 0);
           c                :   in std_logic_vector(9 downto 0);
           generate_block   :   in STD_LOGIC;
           score            :   in integer range 0 to 999;
           clk              :   in std_logic;
           block_type       :   inout STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
           hundreds         :   out STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
           tens             :   out STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
           ones             :   out STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
           vga_output       :   out std_logic
     );
end week421;

architecture Structural of week421 is
    component score_keeper
        Port (
            score    : in integer range 0 to 999;
            clk      : in std_logic;
            hundreds : out STD_LOGIC_VECTOR (6 downto 0);
            tens     : out STD_LOGIC_VECTOR (6 downto 0);
            ones     : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
    
    component board
        Port (
            nReset      :   in std_logic;
            r           :   in std_logic_vector(8 downto 0);
            c           :   in std_logic_vector(9 downto 0);
            block_type  :   in STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
            clk         :   in std_logic;
            vga_output  :   out std_logic
        );
    end component;
    
    component block_generator
        Port ( 
            generate_block : in STD_LOGIC;
            block_type : inout STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
            clk : in STD_LOGIC
        );
    end component;
    
begin
    GameBoard : board port map (    nReset => nReset,
                                    r => r,
                                    c => c,
                                    clk => clk,
                                    vga_output => vga_output);
                                    
    BlockGenerator : block_generator port map ( generate_block => generate_block,
                                                block_type => block_type,
                                                clk => clk);
                                                
    ScoreKeeper : score_keeper port map (   score => score,
                                            clk => clk,
                                            hundreds => hundreds,
                                            tens => tens,
                                            ones => ones);

end Structural;
