library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library STD;
use STD.ENV.ALL;
library XIL_DEFAULTLIB;
use XIL_DEFAULTLIB.all;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    signal clk : std_logic := '0';
    
    -- observation signals
    signal reg1_obs : std_logic_vector(31 downto 0) := (others => '0');
    signal reg2_obs : std_logic_vector(31 downto 0) := (others => '0');
    signal reg3_obs : std_logic_vector(31 downto 0) := (others => '0');

    component top port(
        clk      : in std_logic;
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0));
    end component;

begin

    uut : top port map(
        clk      => clk,
        reg1_out => reg1_obs,
        reg2_out => reg2_obs,
        reg3_out => reg3_obs);

    clk <= not clk after 5ns;

    process
    begin
        wait;
    end process;

    process
    begin
        wait for 250ns;
        
        assert (reg1_obs = x"00000013")
            report "FAIL: R1 expected 0x13"
            severity failure;
            
        assert (reg2_obs = x"00000014")
            report "FAIL: R2 expected 0x14"
            severity failure;
        
        assert (reg3_obs = x"00000027")
            report "FAIL: R3 expected 0x27, ADDGT should have fired"
            severity failure;
        
        report "PASS: all assertions passed";
        wait;
    end process;

end Behavioral;