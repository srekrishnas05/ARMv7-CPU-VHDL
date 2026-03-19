library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aludecoder is
    port (
        ALUOp : in std_logic;
        funct : in std_logic_vector(4 downto 0);
        ALUCO : out std_logic_vector(2 downto 0);
        Flagw : out std_logic_vector(1 downto 0);
        nowrite : out std_logic
        );
end aludecoder;

architecture Behavioral of aludecoder is

begin
process(all)
    begin
    ALUCO <= "000";
    flagw <= "00";
    nowrite <= '0';
    if (ALUOP = '0') then
        ALUCO <= "000";
        Flagw <= "00";
    elsif (ALUop = '1') then
        if (funct(4 downto 1) = "0100") then
            ALUCO <= "000";
            if (funct(0) = '0') then
                flagw <= "00";
            else 
                flagw <= "11";
            end if;
        elsif (funct(4 downto 1) = "0010") then
            ALUCO <= "001";
            if (funct(0) = '0') then
                flagw <= "00";
            else 
                flagw <= "11";
            end if;
        elsif (funct(4 downto 1) = "0000") then
            ALUCO <= "010";
            if (funct(0) = '0') then
                flagw <= "00";
            else 
                flagw <= "10";
            end if;
        elsif (funct(4 downto 1) = "1100") then
            ALUCO <= "011"; 
            if (funct(0) = '0') then
                flagw <= "00";
            else 
                flagw <= "10";
            end if;
        elsif (funct(4 downto 1) = "1111") then
            ALUCO <= "100";
            if (funct(0) = '0') then
                flagw <= "00";
            else 
                flagw <= "10";
            end if;
        elsif (funct(4 downto 1) = "1010") then
            ALUCO <= "001";
            flagw <= "11";
            nowrite <= '1';
        end if;
    end if;    
end process;                                                      
end Behavioral;
