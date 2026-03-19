library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maindecoder is
    port(
        a : in std_logic_vector(31 downto 0);  
        opcode : in std_logic_vector(1 downto 0);
        funct5, funct0 : in std_logic;
        B, M2R, MW, ALUSrc, RegW, ALUop1 : out std_logic;
        immsrc, Regsrc : out std_logic_vector(1 downto 0) 
    );
end maindecoder;

architecture Behavioral of maindecoder is

begin
    process(all)
    begin
        B <= '0';
        M2R <= '0';
        MW <= '0';
        ALUSRC <= '0';
        REGw <= '0';
        aluop1 <= '0';
        immsrc <= "00";
        regsrc <= "00";
        if (opcode = "00" and funct5 = '0') then
            b <= '0';
            m2r <= '0';
            mw <= '0';
            alusrc <= '0';
            regw <= '1';
            aluop1 <= '1';
            immsrc <= "00";
            regsrc <= "00";
        elsif (opcode = "00" and funct5 = '1') then
            b <= '0';
            m2r <= '0';
            mw <= '0';
            alusrc <= '1';
            regw <= '1';
            aluop1 <= '1';
            immsrc <= "00";
            regsrc <= "00";
        elsif (opcode = "01" and funct0 = '0') then
            b <= '0';
            m2r <= '0';
            mw <= '1';
            alusrc <= '1';
            regw <= '0';
            aluop1 <= '0';
            immsrc <= "01";
            regsrc <= "10";                
        elsif (opcode = "01" and funct0 = '1') then
            b <= '0';
            m2r <= '1';
            mw <= '0';
            alusrc <= '1';
            regw <= '1';
            aluop1 <= '0';
            immsrc <= "01";
            regsrc <= "00";
        elsif (opcode = "11") then
            b <= '1';
            m2r <= '0';
            mw <= '0';
            alusrc <= '1';
            regw <= '0';
            aluop1 <= '0';
            immsrc <= "10";
            regsrc <= "01";
        end if;                
        if (a = x"E320F000") then
            regw <= '0';
        end if;
    end process;         
end Behavioral;
