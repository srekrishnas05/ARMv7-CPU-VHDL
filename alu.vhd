library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
        a, b : in  std_logic_vector(31 downto 0);
        alu_ctrl : in  std_logic_vector(2 downto 0); -- 000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR
        result : out std_logic_vector(31 downto 0);
        flags : out std_logic_vector(3 downto 0)  -- N Z C V
    );
end ALU;

architecture Behavioral of ALU is

signal N,Z,C,V : std_logic;

begin
process(all)
variable res : std_logic_vector(31 downto 0);
variable P, G, S : std_logic_vector(31 downto 0);
variable Carry : std_logic_vector(32 downto 0);
variable B_in : std_logic_vector(31 downto 0);
begin

    Carry := (others => '0');
    B_in := b;
    P := (others => '0');
    G := (others => '0');
    S := (others => '0');
    N <= '0';
    Z <= '0';
    C <= '0';
    V <= '0';

    if (alu_ctrl = "000") or (alu_ctrl = "001") then
        if alu_ctrl = "001" then
            B_in  := not b;
            Carry(0) := '1';
        else
            Carry(0) := '0';
        end if;

        for i in 0 to 31 loop
            P(i) := a(i) xor B_in(i);
            G(i) := a(i) and B_in(i);
            Carry(i+1) := G(i) or (P(i) and Carry(i));
            S(i) := P(i) xor Carry(i);
        end loop;
        res := S;
        C <= Carry(32);

        if alu_ctrl = "000" then
            if (a(31) = b(31)) and (res(31) /= a(31)) then
                V <= '1';
            end if;
        else
            if (a(31) /= b(31)) and (res(31) /= a(31)) then
                V <= '1';
            end if;
        end if;
    elsif alu_ctrl = "010" then
        res := a and b;
    elsif alu_ctrl = "011" then
        res := a or b;
    elsif alu_ctrl = "100" then
        res := a xor b;
    else
        res := (others => '0');
    end if;

    N <= res(31);
    if res = x"00000000" then
        Z <= '1';
    end if;
    result <= res;
    flags  <= N & Z & C & V;
end process;
end Behavioral;