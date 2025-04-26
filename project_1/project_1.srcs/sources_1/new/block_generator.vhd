library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity block_generator is
    Port ( generate_block : in STD_LOGIC;
           block_type : buffer STD_LOGIC_VECTOR(2 downto 0);
           clk : in STD_LOGIC);
end block_generator;

architecture Dataflow of block_generator is
    signal lfsr : STD_LOGIC_VECTOR(7 downto 0) := "10111001";                                   -- seed
    
begin
    block_type <= lfsr(2 downto 0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            if rising_edge(generate_block) then
                lfsr <= lfsr(6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
                while not std_match(block_type, "000") loop
                    lfsr <= lfsr(6 downto 0) & (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
                end loop;
            end if;
        end if;
    end process;
end Dataflow;