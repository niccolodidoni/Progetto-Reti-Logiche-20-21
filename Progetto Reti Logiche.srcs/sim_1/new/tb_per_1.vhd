library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_per_1 is
end tb_per_1;

architecture tb_per_1_arch of tb_per_1 is
constant c_CLOCK_PERIOD         : time := 15 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

signal RAM: ram_type := (  0 => std_logic_vector(to_unsigned(7  , 8)),
                           1 => std_logic_vector(to_unsigned(1  , 8)),
                           2 => std_logic_vector(to_unsigned(246 , 8)), -- Expected Output   9 -> 255
                           3 => std_logic_vector(to_unsigned(169 , 8)), -- Expected Output  10 -> 255
                           4 => std_logic_vector(to_unsigned( 53 , 8)), -- Expected Output  11 ->  32
                           5 => std_logic_vector(to_unsigned(225 , 8)), -- Expected Output  12 -> 255
                           6 => std_logic_vector(to_unsigned( 37 , 8)), -- Expected Output  13 ->   0
                           7 => std_logic_vector(to_unsigned(160 , 8)), -- Expected Output  14 -> 246
                           8 => std_logic_vector(to_unsigned(217 , 8)), -- Expected Output  15 -> 255
                        others => (others =>'0'));
component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_rst         : in  std_logic;
      i_start       : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk     => tb_clk,
          i_rst     => tb_rst,
          i_start   => tb_start,
          i_data    => mem_o_data,
          o_address => mem_address,
          o_done    => tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    => mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
    if tb_clk'event and tb_clk = '1' then
        if enable_wire = '1' then
            if mem_we = '1' then
                RAM(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
            end if;
        end if;
    end if;
end process;


test : process is
begin
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;

    -- Immagine originale = [ 246, 169, 53, 225, 37, 160, 217, ]
    -- Immagine di output = [ 255, 255, 32, 255, 0, 246, 255, ]
    assert RAM(  9) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(  9))))  severity failure;
    assert RAM( 10) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 10))))  severity failure;
    assert RAM( 11) = std_logic_vector(to_unsigned( 32 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  32 found " & integer'image(to_integer(unsigned(RAM( 11))))  severity failure;
    assert RAM( 12) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 12))))  severity failure;
    assert RAM( 13) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM( 13))))  severity failure;
    assert RAM( 14) = std_logic_vector(to_unsigned(246 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 246 found " & integer'image(to_integer(unsigned(RAM( 14))))  severity failure;
    assert RAM( 15) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 15))))  severity failure;


    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end tb_per_1_arch;
