library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_1_per is
end tb_1_per;

architecture tb_1_per_arch of tb_1_per is
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

signal RAM: ram_type := (  0 => std_logic_vector(to_unsigned(1  , 8)),
                           1 => std_logic_vector(to_unsigned(10  , 8)),
                           2 => std_logic_vector(to_unsigned( 73 , 8)), -- Expected Output  12 -> 100
                           3 => std_logic_vector(to_unsigned(158 , 8)), -- Expected Output  13 -> 255
                           4 => std_logic_vector(to_unsigned( 23 , 8)), -- Expected Output  14 ->   0
                           5 => std_logic_vector(to_unsigned(193 , 8)), -- Expected Output  15 -> 255
                           6 => std_logic_vector(to_unsigned(120 , 8)), -- Expected Output  16 -> 194
                           7 => std_logic_vector(to_unsigned( 71 , 8)), -- Expected Output  17 ->  96
                           8 => std_logic_vector(to_unsigned( 39 , 8)), -- Expected Output  18 ->  32
                           9 => std_logic_vector(to_unsigned(199 , 8)), -- Expected Output  19 -> 255
                          10 => std_logic_vector(to_unsigned(111 , 8)), -- Expected Output  20 -> 176
                          11 => std_logic_vector(to_unsigned(188 , 8)), -- Expected Output  21 -> 255
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

    -- Immagine originale = [ 73, 158, 23, 193, 120, 71, 39, 199, 111, 188, ]
    -- Immagine di output = [ 100, 255, 0, 255, 194, 96, 32, 255, 176, 255, ]
    assert RAM( 12) = std_logic_vector(to_unsigned(100 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 100 found " & integer'image(to_integer(unsigned(RAM( 12))))  severity failure;
    assert RAM( 13) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 13))))  severity failure;
    assert RAM( 14) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM( 14))))  severity failure;
    assert RAM( 15) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 15))))  severity failure;
    assert RAM( 16) = std_logic_vector(to_unsigned(194 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 194 found " & integer'image(to_integer(unsigned(RAM( 16))))  severity failure;
    assert RAM( 17) = std_logic_vector(to_unsigned( 96 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  96 found " & integer'image(to_integer(unsigned(RAM( 17))))  severity failure;
    assert RAM( 18) = std_logic_vector(to_unsigned( 32 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  32 found " & integer'image(to_integer(unsigned(RAM( 18))))  severity failure;
    assert RAM( 19) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 19))))  severity failure;
    assert RAM( 20) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM( 20))))  severity failure;
    assert RAM( 21) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 21))))  severity failure;


    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end tb_1_per_arch;
