library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity block_generator is
    Port ( generate_block : in STD_LOGIC;
           next_block : buffer STD_LOGIC_VECTOR(2 downto 0);
           clk : in STD_LOGIC
    );
end block_generator;

architecture Dataflow of block_generator is
    signal lfsr0 : STD_LOGIC_VECTOR(7 downto 0) := "10111001";                                  -- seed for LFSR0
    signal lfsr1 : STD_LOGIC_VECTOR(7 downto 0) := "00110101";                                  -- seed for LFSR1
    signal lfsr2 : STD_LOGIC_VECTOR(7 downto 0) := "11110000";                                  -- seed for LFSR2
    
    signal generate_block_vector : std_logic_vector(1 downto 0);
    
begin
    -- connect LFSRs to the block type
    next_block(0) <= lfsr0(0);
    next_block(1) <= lfsr1(0);
    next_block(2) <= lfsr2(0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            generate_block_vector <= generate_block_vector(0) & generate_block;
            if generate_block_vector = "01" then
                report "new block";
                -- shift all 3 LFSRs to generate a new block type
                lfsr0 <= lfsr0(6 downto 0) & (lfsr0(7) xor lfsr0(5) xor lfsr0(4) xor lfsr0(3));
                lfsr1 <= lfsr1(6 downto 0) & (lfsr1(7) xor lfsr1(5) xor lfsr1(4) xor lfsr1(3));
                lfsr2 <= lfsr2(6 downto 0) & (lfsr2(7) xor lfsr2(5) xor lfsr2(4) xor lfsr2(3));
                   
                -- if the block type is invalid, keep shifting until it becomes valid
                while std_match(next_block, "000") loop
                    lfsr0 <= lfsr0(6 downto 0) & (lfsr0(7) xor lfsr0(5) xor lfsr0(4) xor lfsr0(3));
                    lfsr1 <= lfsr1(6 downto 0) & (lfsr1(7) xor lfsr1(5) xor lfsr1(4) xor lfsr1(3));
                    lfsr2 <= lfsr2(6 downto 0) & (lfsr2(7) xor lfsr2(5) xor lfsr2(4) xor lfsr2(3));
                end loop;
            end if;
        end if;
    end process;
end Dataflow;