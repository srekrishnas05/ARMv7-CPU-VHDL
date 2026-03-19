library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controlunit is
    port (
        clk : in std_logic;
        instr : in std_logic_vector(31 downto 0);
        aluflag : in std_logic_vector(3 downto 0);
        flagwm : in std_logic_vector(1 downto 0);
        pcsrc, regwrite, memwrite : out std_logic;
        memtoreg, alusrc : out std_logic;
        immsrc, regsrc : out std_logic_vector(1 downto 0);
        aluco : out std_logic_vector(2 downto 0);
        flagw : out std_logic_vector(1 downto 0)
    );
end controlunit;

architecture Behavioral of controlunit is
    signal b_s, m2r_s, mw_s, alusrc_s, regw_s, aluop_s : std_logic;
    signal immsrc_s, regsrc_s : std_logic_vector(1 downto 0);
    signal flagw_s : std_logic_vector(1 downto 0);
    signal aluco_s : std_logic_vector(2 downto 0);
    signal pcs_s   : std_logic;
    signal flags_s : std_logic_vector(3 downto 0) := (others => '0');
    signal nowrite_s : std_logic;

    component maindecoder port(
        a : in std_logic_vector(31 downto 0);
        opcode : in std_logic_vector(1 downto 0);
        funct5, funct0 : in std_logic;
        B, M2R, MW, ALUSrc, RegW, ALUop1 : out std_logic;
        immsrc, regsrc : out std_logic_vector(1 downto 0));
    end component;

    component aludecoder port(
        ALUOp : in std_logic;
        funct : in std_logic_vector(4 downto 0);
        ALUCO : out std_logic_vector(2 downto 0);
        Flagw : out std_logic_vector(1 downto 0);
        nowrite : out std_logic);
    end component;

    component pclogic port(
        Rd : in std_logic_vector(3 downto 0);
        regw : in std_logic;
        b : in std_logic;
        pcs : out std_logic);
    end component;

    component condlogic port(
        clk : in std_logic;
        cond : in std_logic_vector(3 downto 0);
        flag : in std_logic_vector(3 downto 0);
        pcsrcin, regwritein, memwritein : in std_logic;
        flagwin : in std_logic_vector(1 downto 0);
        aluflag : in std_logic_vector(3 downto 0);
        pcsrc, regwrite, memwrite : out std_logic;
        uflags : out std_logic_vector(3 downto 0);
        nowrite : in std_logic);
    end component;

begin
    flagw <= flagw_s;

    md : maindecoder port map(
        a      => instr,
        opcode => instr(27 downto 26),
        funct5 => instr(25),
        funct0 => instr(20),
        b => b_s, m2r => m2r_s, mw => mw_s,
        alusrc => alusrc_s, regw => regw_s, aluop1 => aluop_s,
        immsrc => immsrc_s, regsrc => regsrc_s);

    ad : aludecoder port map(
        aluop   => aluop_s,
        funct   => instr(24 downto 20),
        aluco   => aluco_s,
        flagw   => flagw_s,
        nowrite => nowrite_s);

    pl : pclogic port map(
        rd   => instr(15 downto 12),
        regw => regw_s,
        b    => b_s,
        pcs  => pcs_s);

    cl : condlogic port map(
        clk        => clk,
        cond       => instr(31 downto 28),
        flag       => flags_s,
        pcsrcin    => pcs_s,
        regwritein => regw_s,
        memwritein => mw_s,
        flagwin    => flagwm,
        aluflag    => aluflag,
        pcsrc      => pcsrc,
        regwrite   => regwrite,
        memwrite   => memwrite,
        uflags     => flags_s,
        nowrite    => nowrite_s);

    memtoreg <= m2r_s;
    alusrc   <= alusrc_s;
    immsrc   <= immsrc_s;
    regsrc   <= regsrc_s;
    aluco    <= aluco_s;

end Behavioral;