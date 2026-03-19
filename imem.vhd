library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;


entity imem is
    port (
        addr : in std_logic_vector(31 downto 0);
        rd   : out std_logic_vector(31 downto 0)
    );
end imem;

architecture Behavioral of imem is
    type imem_t is array (0 to 255) of std_logic_vector(31 downto 0);
    
    impure function load_mem(filename : string) return imem_t is
        file f : text open read_mode is filename;
        variable l : line;
        variable mem : imem_t := (others => (others => '0'));
        variable i : integer := 0;
        variable val : std_logic_vector(31 downto 0);
        variable good : boolean;
    begin
        while not endfile(f) loop
            readline(f, l);
            hread(l, val, good);
            if good then
                mem(i) := val;
                i := i + 1;
            end if;
        end loop;
        return mem;
    end function;

    signal mem : imem_t := (
        0  => x"E2801013",  -- ADD R1, R0, #19
        1  => x"E2802014",  -- ADD R2, R0, #20
        2  => x"E1520001",  -- CMP R2, R1
        3 => x"00813002",  -- ADDEQ R3, R1, R2
        4 => x"90813002",  -- ADDLS R3, R1, R2
        5 => x"C0813002",  -- ADDGT R3, R1, R2
        6 => x"80813002",  -- ADDHI R3, R1, R2
        7 => x"E5804004",  -- STR R4, [R0, #4]
        others => x"E320F000");
begin
    rd <= mem(to_integer(unsigned(addr(9 downto 2))));
end Behavioral;