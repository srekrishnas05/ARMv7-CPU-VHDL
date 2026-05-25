library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcache is
    port (
        clk : in  std_logic;
        addr : in  std_logic_vector(31 downto 0);
        wdata : in  std_logic_vector(31 downto 0);
        we : in  std_logic;
        rdata : out std_logic_vector(31 downto 0);
        hit : out std_logic;
        mem_addr : out std_logic_vector(31 downto 0);
        mem_wdata : out std_logic_vector(31 downto 0);
        mem_we : out std_logic;
        mem_rdata : in  std_logic_vector(31 downto 0)
    );
end dcache;

architecture behavioral of dcache is
    type tag_array_t is array(0 to 3, 0 to 3) of std_logic_vector(27 downto 0);
    signal tag_ram : tag_array_t := (others => (others => (others => '0'))); 

    type data_array_t is array(0 to 3, 0 to 3) of std_logic_vector(31 downto 0);
    signal data_ram : data_array_t := (others => (others => (others => '0')));

    type valid_array_t is array(0 to 3, 0 to 3) of std_logic;
    signal valid_ram : valid_array_t := (others => (others => '0'));

    type dirty_array_t is array(0 to 3, 0 to 3) of std_logic;
    signal dirty_ram : dirty_array_t := (others => (others => '0'));

    type lru_cnt_t is array(0 to 3) of unsigned(1 downto 0);
    signal lru_cnt : lru_cnt_t := (others => (others => '0'));

begin    
process(all)
    variable set_idx  : integer range 0 to 3;
    variable addr_tag : std_logic_vector(27 downto 0);
    variable hit_way  : integer range 0 to 4; 
    variable hit_flag : std_logic;
    variable evict_way : integer range 0 to 3;

begin
    rdata <= (others => '0');
    mem_addr <= (others => '0');
    mem_wdata <= (others => '0');
    mem_we <= '0';
    hit <= '0';
    hit_flag := '0';
    hit_way := 4;

    set_idx := to_integer(unsigned(addr(3 downto 2)));
    addr_tag := addr(31 downto 4);

    for w in 0 to 3 loop
        if (valid_ram(set_idx, w) = '1') and (tag_ram(set_idx, w) = addr_tag) then
            hit_way  := w;
            hit_flag := '1';
        end if;
    end loop;

    evict_way := to_integer(lru_cnt(set_idx));

    if hit_flag = '1' then
            hit <= '1';
            rdata <= data_ram(set_idx, hit_way);
    else
        if (valid_ram(set_idx, evict_way) = '1') and (dirty_ram(set_idx, evict_way) = '1') then
            mem_addr <= tag_ram(set_idx, evict_way) & std_logic_vector(to_unsigned(set_idx, 2)) & "00";
            mem_wdata <= data_ram(set_idx, evict_way);
            mem_we <= '1';
        else
            mem_addr <= addr;
        end if;
        if we = '0' then
            rdata <= mem_rdata;
        end if;
    end if;
end process;

process(clk)
    variable set_idx  : integer range 0 to 3;
    variable addr_tag : std_logic_vector(27 downto 0);
    variable hit_way  : integer range 0 to 4; 
    variable hit_flag : std_logic;
    variable evict_way : integer range 0 to 3;
begin
    if rising_edge(clk) then
        set_idx  := to_integer(unsigned(addr(3 downto 2)));
        addr_tag := addr(31 downto 4);
        hit_way  := 4;
        hit_flag := '0';

        for w in 0 to 3 loop
            if (valid_ram(set_idx, w) = '1') and (tag_ram(set_idx, w) = addr_tag) then
                hit_way  := w;
                hit_flag := '1';
            end if;
        end loop;

        evict_way := to_integer(lru_cnt(set_idx));

        if hit_flag = '1' then
            if we = '1' then
                data_ram(set_idx, hit_way) <= wdata;
                dirty_ram(set_idx, hit_way) <= '1';
            end if;
            lru_cnt(set_idx) <= lru_cnt(set_idx) + 1;
        else
            tag_ram(set_idx, evict_way) <= addr_tag;
            valid_ram(set_idx, evict_way) <= '1';
            lru_cnt(set_idx) <= lru_cnt(set_idx) + 1;
            if we = '1' then
                data_ram(set_idx, evict_way) <= wdata;
                dirty_ram(set_idx, evict_way) <= '1';
            else
                data_ram(set_idx, evict_way) <= mem_rdata;
                dirty_ram(set_idx, evict_way) <= '0';
            end if;
        end if;
    end if;
end process;
end behavioral;

