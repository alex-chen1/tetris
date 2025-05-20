library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity block_generator is
    Port ( generate_block : in STD_LOGIC;
           curr_block : out STD_LOGIC_VECTOR(2 downto 0);
           next_block : buffer STD_LOGIC_VECTOR(2 downto 0);
           done_gen : out std_logic;
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
    variable vlfsr0 : std_logic_vector(7 downto 0);
    variable vlfsr1 : std_logic_vector(7 downto 0);
    variable vlfsr2 : std_logic_vector(7 downto 0);
    variable vnext_block : std_logic_vector(2 downto 0);
    begin
        if rising_edge(clk) then
            generate_block_vector <= generate_block_vector(0) & generate_block;
            if generate_block_vector = "01" then
                curr_block <= next_block;
                
                vlfsr0 := lfsr0;
                vlfsr1 := lfsr1;
                vlfsr2 := lfsr2;
                
                -- shift all 3 LFSRs to generate a new block type
                loop
                    report "stuck in loop";
                    vlfsr0 := vlfsr0(6 downto 0) & (vlfsr0(7) xor vlfsr0(5) xor vlfsr0(4) xor vlfsr0(3));
                    vlfsr1 := vlfsr1(6 downto 0) & (vlfsr1(7) xor vlfsr1(5) xor vlfsr1(4) xor vlfsr1(3));
                    vlfsr2 := vlfsr2(6 downto 0) & (vlfsr2(7) xor vlfsr2(5) xor vlfsr2(4) xor vlfsr2(3));
                    vnext_block := vlfsr2(0) & vlfsr1(0) & vlfsr0(0);
                    exit when vnext_block /= "000";
                end loop;
                
                lfsr0 <= vlfsr0;
                lfsr1 <= vlfsr1;
                lfsr2 <= vlfsr2;
                
                done_gen <= '1';
            else
                done_gen <= '0';
            end if;
        end if;
    end process;
end Dataflow;