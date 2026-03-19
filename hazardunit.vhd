library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazardunit is
    port(
        wa3m, wa3w, wa3e : in std_logic_vector(4 downto 0);
        ra1e, ra2e : in std_logic_vector(4 downto 0);
        regwritem, regwritew, memtorege : in std_logic;
        ra1d, ra2d : in std_logic_vector(4 downto 0); 
        forwardae, forwardbe : out std_logic_vector(1 downto 0);
        stall : out std_logic
    );
end hazardunit;

architecture behavioral of hazardunit is
begin
    process(all)
    begin
        forwardae <= "00";
        forwardbe <= "00";
        if (regwritem = '1') and (wa3m = ra1e) then
            forwardae <= "10";
        elsif (regwritew = '1') and (wa3w = ra1e) then
            forwardae <= "01";
        end if;
        if (regwritem = '1') and (wa3m = ra2e) then
            forwardbe <= "10";
        elsif (regwritew = '1') and (wa3w = ra2e) then
            forwardbe <= "01";
        end if;
        if (memtorege = '1') and ((wa3e = ra1d) or (wa3e = ra2d)) then
            stall <= '1';
        else 
            stall <= '0';
        end if;
    end process;
end architecture;
	