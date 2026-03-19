library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    port (
        clk : in std_logic;
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0)
    );
end top;

architecture Behavioral of top is
    signal instr_s    : std_logic_vector(31 downto 0);
    signal aluflags_s : std_logic_vector(3 downto 0);
    signal pcsrc_s, memtoreg_s, memwrite_s, alusrc_s, regwrite_s : std_logic;
    signal immsrc_s, regsrc_s : std_logic_vector(1 downto 0);
    signal aluco_s  : std_logic_vector(2 downto 0);
    signal flagw_s  : std_logic_vector(1 downto 0);
    signal flagwm_s : std_logic_vector(1 downto 0);

    component controlunit port(
        clk     : in std_logic;
        instr   : in std_logic_vector(31 downto 0);
        aluflag : in std_logic_vector(3 downto 0);
        flagwm  : in std_logic_vector(1 downto 0);
        pcsrc, regwrite, memwrite, memtoreg, alusrc : out std_logic;
        immsrc, regsrc : out std_logic_vector(1 downto 0);
        aluco   : out std_logic_vector(2 downto 0);
        flagw   : out std_logic_vector(1 downto 0));
    end component;

    component datapath port(
        clk     : in std_logic;
        flagw   : in std_logic_vector(1 downto 0);
        pcsrc, memtoreg, memwrite, alusrc, regwrite : in std_logic;
        immsrc, regsrc : in std_logic_vector(1 downto 0);
        aluco   : in std_logic_vector(2 downto 0);
        instr   : out std_logic_vector(31 downto 0);
        flagwm  : out std_logic_vector(1 downto 0);
        aluflags : out std_logic_vector(3 downto 0);
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0));
    end component;

begin
    cu : controlunit port map(
        clk      => clk,
        instr    => instr_s,
        aluflag  => aluflags_s,
        flagwm   => flagwm_s,
        pcsrc    => pcsrc_s,
        regwrite => regwrite_s,
        memwrite => memwrite_s,
        memtoreg => memtoreg_s,
        alusrc   => alusrc_s,
        immsrc   => immsrc_s,
        regsrc   => regsrc_s,
        aluco    => aluco_s,
        flagw    => flagw_s);

    dp : datapath port map(
        clk      => clk,
        flagw    => flagw_s,
        pcsrc    => pcsrc_s,
        memtoreg => memtoreg_s,
        memwrite => memwrite_s,
        alusrc   => alusrc_s,
        regwrite => regwrite_s,
        immsrc   => immsrc_s,
        regsrc   => regsrc_s,
        aluco    => aluco_s,
        instr    => instr_s,
        flagwm   => flagwm_s,
        aluflags => aluflags_s,
        reg1_out => reg1_out,
        reg2_out => reg2_out,
        reg3_out => reg3_out);

end Behavioral;