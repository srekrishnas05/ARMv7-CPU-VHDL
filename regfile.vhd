library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regfile is
    port (
        clk : in std_logic;
        
        raddr1 : in std_logic_vector(4 downto 0);
        rdata1 : out std_logic_vector(31 downto 0);
        
        raddr2 : in std_logic_vector(4 downto 0);
        rdata2 : out std_logic_vector(31 downto 0);
        
        r15 : in std_logic_vector(31 downto 0);
        
        we: in std_logic; 
        waddr : in std_logic_vector(4 downto 0);
        wdata : in std_logic_vector(31 downto 0);
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0)
        );
end regfile;
    
architecture Behavioral of regfile is
    type reg_array_t is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array_t := (others => (others => '0'));
begin
    process(all)
        variable wa : integer;
    begin
            wa := to_integer(unsigned(waddr));
            if ((we = '1') and (wa /= 0)) then
                regs(wa) <= wdata;
            end if;
            regs(0) <= (others => '0');
    end process;
    
    process(all)
        variable ra1, ra2 : integer;
    begin
        ra1 := to_integer(unsigned(raddr1));
        ra2 := to_integer(unsigned(raddr2));
        if (ra1 = 0) then
            rdata1 <= (others => '0');
        elsif (ra1 = 15) then
            rdata1 <= r15;
        else 
            rdata1 <= regs(ra1);
        end if;
        if (ra2 = 0) then
            rdata2 <= (others => '0');
        elsif (ra2 = 15) then
            rdata2 <= r15;
        else
            rdata2 <= regs(ra2);
        end if;
    end process;
    reg1_out <= regs(1);
    reg2_out <= regs(2);
    reg3_out <= regs(3);                    
end Behavioral;
