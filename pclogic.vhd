library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pclogic is
    port (
    Rd : in std_logic_vector(3 downto 0);
    regw : in std_logic;
    b : in std_logic;
    pcs : out std_logic 
    );
end pclogic;

architecture Behavioral of pclogic is
begin
    pcs <= '1' when (((rd = "1111") and (regw = '1')) or (b = '1'))
               else '0';
end Behavioral;
