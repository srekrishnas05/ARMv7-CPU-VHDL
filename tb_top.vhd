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
        
        -- test with your own assertions, condlogic or cache is a good place to start and you can just make more regN_out
        
        report "PASS: all assertions passed";
        wait;
    end process;

end Behavioral;
