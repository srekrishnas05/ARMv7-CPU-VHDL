library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    port (
        clk : in std_logic;
        flagw : in std_logic_vector(1 downto 0);
        pcsrc, memtoreg, memwrite, alusrc, regwrite : in std_logic;
        immsrc, regsrc : in std_logic_vector(1 downto 0);
        aluco : in std_logic_vector(2 downto 0);
        instr : out std_logic_vector(31 downto 0);
        flagwm : out std_logic_vector(1 downto 0);
        aluflags : out std_logic_vector(3 downto 0);
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0)
        );
end datapath;

architecture Behavioral of datapath is
    signal pc       : std_logic_vector(31 downto 0) := (others => '0');
    signal pcnext   : std_logic_vector(31 downto 0);
    signal pcplus4f : std_logic_vector(31 downto 0);
    signal instrf   : std_logic_vector(31 downto 0);

    signal instrd   : std_logic_vector(31 downto 0) := (others => '0');
    signal pcplus8d : std_logic_vector(31 downto 0) := (others => '0');
    signal rd1, rd2 : std_logic_vector(31 downto 0);
    signal extimm   : std_logic_vector(31 downto 0);
    signal wa3d     : std_logic_vector(4 downto 0);
    signal ra1, ra2 : std_logic_vector(4 downto 0);
    signal ra1d, ra2d : std_logic_vector(4 downto 0);

    signal rd1e, rd2e, extimme, pcplus8e : std_logic_vector(31 downto 0);
    signal regwritee, memtorege, memwritee, pcsrce, alusrce : std_logic;
    signal alucoe   : std_logic_vector(2 downto 0);
    signal wa3e     : std_logic_vector(4 downto 0);
    signal flagwe   : std_logic_vector(1 downto 0);
    signal srca, srcb     : std_logic_vector(31 downto 0);
    signal aluresult      : std_logic_vector(31 downto 0);
    signal aluflags_s     : std_logic_vector(3 downto 0);
    signal ra1e, ra2e : std_logic_vector(4 downto 0);
    signal forwardae, forwardbe : std_logic_vector(1 downto 0);
    signal srcbpre : std_logic_vector(31 downto 0);

    signal rd2m, aluresultm : std_logic_vector(31 downto 0);
    signal pcsrcm, memwritem, regwritem, memtoregm : std_logic;
    signal wa3m      : std_logic_vector(4 downto 0);
    signal readdata  : std_logic_vector(31 downto 0);
    signal aluflagsm : std_logic_vector(3 downto 0);
    signal flagwm_s  : std_logic_vector(1 downto 0) := (others => '0');

    signal readdataw, aluresultw : std_logic_vector(31 downto 0);
    signal regwritew, memtoregw  : std_logic;
    signal wa3w    : std_logic_vector(4 downto 0);
    signal resultw : std_logic_vector(31 downto 0);
    signal wdata   : std_logic_vector(31 downto 0);
    
    signal flush : std_logic;
    signal stall : std_logic;

    type dmem_t is array (0 to 255) of std_logic_vector(31 downto 0);
    signal dmem : dmem_t := (others => (others => '0'));

    component regfile port(
        clk    : in std_logic;
        raddr1 : in std_logic_vector(4 downto 0);
        rdata1 : out std_logic_vector(31 downto 0);
        raddr2 : in std_logic_vector(4 downto 0);
        rdata2 : out std_logic_vector(31 downto 0);
        we     : in std_logic;
        waddr  : in std_logic_vector(4 downto 0);
        wdata  : in std_logic_vector(31 downto 0);
        r15    : in std_logic_vector(31 downto 0);
        reg1_out : out std_logic_vector(31 downto 0);
        reg2_out : out std_logic_vector(31 downto 0);
        reg3_out : out std_logic_vector(31 downto 0));
    end component;

    component ALU port(
        a, b     : in std_logic_vector(31 downto 0);
        alu_ctrl : in std_logic_vector(2 downto 0);
        result   : out std_logic_vector(31 downto 0);
        flags    : out std_logic_vector(3 downto 0));
    end component;

    component imem port(
        addr : in std_logic_vector(31 downto 0);
        rd   : out std_logic_vector(31 downto 0));
    end component;
    
    component hazardunit port (
        wa3m     : in std_logic_vector(4 downto 0);
        wa3w     : in std_logic_vector(4 downto 0);
        ra1e     : in std_logic_vector(4 downto 0);
        ra2e     : in std_logic_vector(4 downto 0);
        regwritem : in std_logic;
        regwritew : in std_logic;
        wa3e : in std_logic_vector(4 downto 0);
        memtorege : in std_logic;
        ra1d : in std_logic_vector(4 downto 0);
        ra2d : in std_logic_vector(4 downto 0);
        stall : out std_logic;
        forwardae : out std_logic_vector(1 downto 0);
        forwardbe : out std_logic_vector(1 downto 0));
    end component;   

begin
    -- FETCH
    process(clk)
    begin
        if rising_edge(clk) then
            if (stall = '0') then
                pc <= pcnext;
            end if;
        end if;
    end process;

    pcplus4f <= std_logic_vector(unsigned(pc) + 4);
    pcnext   <= aluresultm when pcsrcm = '1' else pcplus4f;

    im : imem port map(
        addr => pc,
        rd   => instrf);
    
    flush <= pcsrcm;
    
    -- F/D PIPELINE REGISTER
    process(clk)
    begin
        if rising_edge(clk) then
            if (stall = '1') then
                null;
            elsif (flush = '1') then
                pcplus8d <= (others => '0');
                instrd <= (others => '0');    
            else
                pcplus8d <= pcplus4f;
                instrd   <= instrf;    
            end if;    
        end if;
    end process;

    -- DECODE
    instr <= instrd;

    ra1  <= "01111" when regsrc(0) = '1' else '0' & instrd(19 downto 16);
    ra2  <= '0' & instrd(15 downto 12) when regsrc(1) = '1' else '0' & instrd(3 downto 0);
    wa3d <= '0' & instrd(15 downto 12);
    ra1d <= ra1;
    ra2d <= ra2;

    rf : regfile port map(
        clk    => clk,
        raddr1 => ra1,
        rdata1 => rd1,
        raddr2 => ra2,
        rdata2 => rd2,
        r15    => pcplus8d,
        we     => regwritew,
        waddr  => wa3w,
        wdata  => wdata,
        reg1_out => reg1_out,
        reg2_out => reg2_out,
        reg3_out => reg3_out);
    
    hu : hazardunit port map(
        wa3m => wa3m,
        wa3w => wa3w,
        regwritem => regwritem,
        regwritew => regwritew,
        ra1e => ra1e,
        ra2e => ra2e,
        forwardae => forwardae,
        forwardbe => forwardbe,
        wa3e => wa3e,
        memtorege => memtorege,
        ra1d => ra1d,
        ra2d => ra2d,
        stall => stall
        );    

    process(all)
    begin
        case immsrc is
            when "00" =>
                extimm <= x"000000" & instrd(7 downto 0);
            when "01" =>
                extimm <= x"000" & "00000000" & instrd(11 downto 0);
            when "10" =>
                extimm <= std_logic_vector(resize(signed(instrd(23 downto 0)), 32));
            when "11" =>
                extimm <= (others => '0');
            when others =>
                extimm <= (others => '0');
        end case;
    end process;

    -- D/E PIPELINE REGISTER
    process(clk)
    begin
        if rising_edge(clk) then
            if (stall = '1') then 
                rd1e      <= (others => '0');
                rd2e      <= (others => '0');
                extimme   <= (others => '0');
                wa3e      <= (others => '0');
                pcplus8e  <= (others => '0');
                regwritee <= '0';
                memtorege <= '0';
                memwritee <= '0';
                pcsrce    <= '0';
                alusrce   <= '0';
                alucoe    <= (others => '0');
                flagwe    <= (others => '0');
                ra1e <= (others => '0');
                ra2e <= (others => '0');
            elsif (flush = '1') then
                rd1e      <= (others => '0');
                rd2e      <= (others => '0');
                extimme   <= (others => '0');
                wa3e      <= (others => '0');
                pcplus8e  <= (others => '0');
                regwritee <= '0';
                memtorege <= '0';
                memwritee <= '0';
                pcsrce    <= '0';
                alusrce   <= '0';
                alucoe    <= (others => '0');
                flagwe    <= (others => '0');
                ra1e <= (others => '0');
                ra2e <= (others => '0');    
            else
                rd1e      <= rd1;
                rd2e      <= rd2;
                extimme   <= extimm;
                wa3e      <= wa3d;
                pcplus8e  <= pcplus8d;
                regwritee <= regwrite;
                memtorege <= memtoreg;
                memwritee <= memwrite;
                pcsrce    <= pcsrc;
                alusrce   <= alusrc;
                alucoe    <= aluco;
                flagwe    <= flagw;
                ra1e <= ra1;
                ra2e <= ra2;
            end if;
        end if;            
    end process;

    -- EXECUTE
    srca <= rd1e when (forwardae = "00") else 
            resultw when (forwardae = "01") else 
            aluresultm;
    srcbpre <= rd2e when (forwardbe = "00") else 
               resultw when (forwardbe = "01") else 
               aluresultm;
    
    srcb <= extimme when alusrce = '1' else srcbpre;

    alu_inst : ALU port map(
        a        => srca,
        b        => srcb,
        alu_ctrl => alucoe,
        result   => aluresult,
        flags    => aluflags_s);

    -- E/M PIPELINE REGISTER
    process(clk)
    begin
        if rising_edge(clk) then
            rd2m       <= srcbpre;
            aluresultm <= aluresult;
            pcsrcm     <= pcsrce;
            memwritem  <= memwritee;
            memtoregm  <= memtorege;
            regwritem  <= regwritee;
            wa3m       <= wa3e;
            aluflagsm  <= aluflags_s;
            flagwm_s   <= flagwe;
        end if;
    end process;

    aluflags <= aluflagsm;
    flagwm   <= flagwm_s;

    -- MEMORY
    process(clk)
    begin
        if rising_edge(clk) then
            if memwritem = '1' then
                dmem(to_integer(unsigned(aluresultm(9 downto 2)))) <= rd2m;
            end if;
        end if;
    end process;
    readdata <= dmem(to_integer(unsigned(aluresultm(9 downto 2))));

    -- M/W PIPELINE REGISTER
    process(clk)
    begin
        if rising_edge(clk) then
            readdataw  <= readdata;
            aluresultw <= aluresultm;
            regwritew  <= regwritem;
            memtoregw  <= memtoregm;
            wa3w       <= wa3m;
        end if;
    end process;

    -- WRITEBACK
    resultw <= readdataw when memtoregw = '1' else aluresultw;
    wdata   <= resultw;

end Behavioral;