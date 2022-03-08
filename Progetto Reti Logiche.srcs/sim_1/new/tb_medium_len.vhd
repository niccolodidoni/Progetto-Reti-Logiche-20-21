library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_medium_len is
end tb_medium_len;

architecture tb_medium_len_arch of tb_medium_len is
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

signal RAM: ram_type := (  0 => std_logic_vector(to_unsigned(5  , 8)),
                           1 => std_logic_vector(to_unsigned(9  , 8)),
                           2 => std_logic_vector(to_unsigned(153 , 8)), -- Expected Output  47 -> 255
                           3 => std_logic_vector(to_unsigned( 79 , 8)), -- Expected Output  48 -> 156
                           4 => std_logic_vector(to_unsigned( 89 , 8)), -- Expected Output  49 -> 176
                           5 => std_logic_vector(to_unsigned(239 , 8)), -- Expected Output  50 -> 255
                           6 => std_logic_vector(to_unsigned( 61 , 8)), -- Expected Output  51 -> 120
                           7 => std_logic_vector(to_unsigned( 57 , 8)), -- Expected Output  52 -> 112
                           8 => std_logic_vector(to_unsigned(156 , 8)), -- Expected Output  53 -> 255
                           9 => std_logic_vector(to_unsigned( 80 , 8)), -- Expected Output  54 -> 158
                          10 => std_logic_vector(to_unsigned(212 , 8)), -- Expected Output  55 -> 255
                          11 => std_logic_vector(to_unsigned( 39 , 8)), -- Expected Output  56 ->  76
                          12 => std_logic_vector(to_unsigned(184 , 8)), -- Expected Output  57 -> 255
                          13 => std_logic_vector(to_unsigned(211 , 8)), -- Expected Output  58 -> 255
                          14 => std_logic_vector(to_unsigned(236 , 8)), -- Expected Output  59 -> 255
                          15 => std_logic_vector(to_unsigned(149 , 8)), -- Expected Output  60 -> 255
                          16 => std_logic_vector(to_unsigned(160 , 8)), -- Expected Output  61 -> 255
                          17 => std_logic_vector(to_unsigned(  5 , 8)), -- Expected Output  62 ->   8
                          18 => std_logic_vector(to_unsigned(218 , 8)), -- Expected Output  63 -> 255
                          19 => std_logic_vector(to_unsigned( 75 , 8)), -- Expected Output  64 -> 148
                          20 => std_logic_vector(to_unsigned(248 , 8)), -- Expected Output  65 -> 255
                          21 => std_logic_vector(to_unsigned( 62 , 8)), -- Expected Output  66 -> 122
                          22 => std_logic_vector(to_unsigned(225 , 8)), -- Expected Output  67 -> 255
                          23 => std_logic_vector(to_unsigned(136 , 8)), -- Expected Output  68 -> 255
                          24 => std_logic_vector(to_unsigned( 56 , 8)), -- Expected Output  69 -> 110
                          25 => std_logic_vector(to_unsigned( 30 , 8)), -- Expected Output  70 ->  58
                          26 => std_logic_vector(to_unsigned( 57 , 8)), -- Expected Output  71 -> 112
                          27 => std_logic_vector(to_unsigned(146 , 8)), -- Expected Output  72 -> 255
                          28 => std_logic_vector(to_unsigned(  1 , 8)), -- Expected Output  73 ->   0
                          29 => std_logic_vector(to_unsigned( 18 , 8)), -- Expected Output  74 ->  34
                          30 => std_logic_vector(to_unsigned(118 , 8)), -- Expected Output  75 -> 234
                          31 => std_logic_vector(to_unsigned(245 , 8)), -- Expected Output  76 -> 255
                          32 => std_logic_vector(to_unsigned( 37 , 8)), -- Expected Output  77 ->  72
                          33 => std_logic_vector(to_unsigned(200 , 8)), -- Expected Output  78 -> 255
                          34 => std_logic_vector(to_unsigned( 20 , 8)), -- Expected Output  79 ->  38
                          35 => std_logic_vector(to_unsigned( 59 , 8)), -- Expected Output  80 -> 116
                          36 => std_logic_vector(to_unsigned(108 , 8)), -- Expected Output  81 -> 214
                          37 => std_logic_vector(to_unsigned( 85 , 8)), -- Expected Output  82 -> 168
                          38 => std_logic_vector(to_unsigned(227 , 8)), -- Expected Output  83 -> 255
                          39 => std_logic_vector(to_unsigned(117 , 8)), -- Expected Output  84 -> 232
                          40 => std_logic_vector(to_unsigned(126 , 8)), -- Expected Output  85 -> 250
                          41 => std_logic_vector(to_unsigned(220 , 8)), -- Expected Output  86 -> 255
                          42 => std_logic_vector(to_unsigned(188 , 8)), -- Expected Output  87 -> 255
                          43 => std_logic_vector(to_unsigned( 55 , 8)), -- Expected Output  88 -> 108
                          44 => std_logic_vector(to_unsigned(218 , 8)), -- Expected Output  89 -> 255
                          45 => std_logic_vector(to_unsigned( 91 , 8)), -- Expected Output  90 -> 180
                          46 => std_logic_vector(to_unsigned(152 , 8)), -- Expected Output  91 -> 255
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

    -- Immagine originale = [ 153, 79, 89, 239, 61, 57, 156, 80, 212, 39, 184, 211, 236, 149, 160, 5, 218, 75, 248, 62, 225, 136, 56, 30, 57, 146, 1, 18, 118, 245, 37, 200, 20, 59, 108, 85, 227, 117, 126, 220, 188, 55, 218, 91, 152, ]
    -- Immagine di output = [ 255, 156, 176, 255, 120, 112, 255, 158, 255, 76, 255, 255, 255, 255, 255, 8, 255, 148, 255, 122, 255, 255, 110, 58, 112, 255, 0, 34, 234, 255, 72, 255, 38, 116, 214, 168, 255, 232, 250, 255, 255, 108, 255, 180, 255, ]
    assert RAM( 47) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 47))))  severity failure;
    assert RAM( 48) = std_logic_vector(to_unsigned(156 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 156 found " & integer'image(to_integer(unsigned(RAM( 48))))  severity failure;
    assert RAM( 49) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM( 49))))  severity failure;
    assert RAM( 50) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 50))))  severity failure;
    assert RAM( 51) = std_logic_vector(to_unsigned(120 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 120 found " & integer'image(to_integer(unsigned(RAM( 51))))  severity failure;
    assert RAM( 52) = std_logic_vector(to_unsigned(112 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 112 found " & integer'image(to_integer(unsigned(RAM( 52))))  severity failure;
    assert RAM( 53) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 53))))  severity failure;
    assert RAM( 54) = std_logic_vector(to_unsigned(158 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 158 found " & integer'image(to_integer(unsigned(RAM( 54))))  severity failure;
    assert RAM( 55) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 55))))  severity failure;
    assert RAM( 56) = std_logic_vector(to_unsigned( 76 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  76 found " & integer'image(to_integer(unsigned(RAM( 56))))  severity failure;
    assert RAM( 57) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 57))))  severity failure;
    assert RAM( 58) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 58))))  severity failure;
    assert RAM( 59) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 59))))  severity failure;
    assert RAM( 60) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 60))))  severity failure;
    assert RAM( 61) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 61))))  severity failure;
    assert RAM( 62) = std_logic_vector(to_unsigned(  8 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   8 found " & integer'image(to_integer(unsigned(RAM( 62))))  severity failure;
    assert RAM( 63) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 63))))  severity failure;
    assert RAM( 64) = std_logic_vector(to_unsigned(148 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 148 found " & integer'image(to_integer(unsigned(RAM( 64))))  severity failure;
    assert RAM( 65) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 65))))  severity failure;
    assert RAM( 66) = std_logic_vector(to_unsigned(122 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 122 found " & integer'image(to_integer(unsigned(RAM( 66))))  severity failure;
    assert RAM( 67) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 67))))  severity failure;
    assert RAM( 68) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 68))))  severity failure;
    assert RAM( 69) = std_logic_vector(to_unsigned(110 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 110 found " & integer'image(to_integer(unsigned(RAM( 69))))  severity failure;
    assert RAM( 70) = std_logic_vector(to_unsigned( 58 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  58 found " & integer'image(to_integer(unsigned(RAM( 70))))  severity failure;
    assert RAM( 71) = std_logic_vector(to_unsigned(112 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 112 found " & integer'image(to_integer(unsigned(RAM( 71))))  severity failure;
    assert RAM( 72) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 72))))  severity failure;
    assert RAM( 73) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM( 73))))  severity failure;
    assert RAM( 74) = std_logic_vector(to_unsigned( 34 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  34 found " & integer'image(to_integer(unsigned(RAM( 74))))  severity failure;
    assert RAM( 75) = std_logic_vector(to_unsigned(234 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 234 found " & integer'image(to_integer(unsigned(RAM( 75))))  severity failure;
    assert RAM( 76) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 76))))  severity failure;
    assert RAM( 77) = std_logic_vector(to_unsigned( 72 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  72 found " & integer'image(to_integer(unsigned(RAM( 77))))  severity failure;
    assert RAM( 78) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 78))))  severity failure;
    assert RAM( 79) = std_logic_vector(to_unsigned( 38 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  38 found " & integer'image(to_integer(unsigned(RAM( 79))))  severity failure;
    assert RAM( 80) = std_logic_vector(to_unsigned(116 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 116 found " & integer'image(to_integer(unsigned(RAM( 80))))  severity failure;
    assert RAM( 81) = std_logic_vector(to_unsigned(214 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 214 found " & integer'image(to_integer(unsigned(RAM( 81))))  severity failure;
    assert RAM( 82) = std_logic_vector(to_unsigned(168 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 168 found " & integer'image(to_integer(unsigned(RAM( 82))))  severity failure;
    assert RAM( 83) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 83))))  severity failure;
    assert RAM( 84) = std_logic_vector(to_unsigned(232 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 232 found " & integer'image(to_integer(unsigned(RAM( 84))))  severity failure;
    assert RAM( 85) = std_logic_vector(to_unsigned(250 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 250 found " & integer'image(to_integer(unsigned(RAM( 85))))  severity failure;
    assert RAM( 86) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 86))))  severity failure;
    assert RAM( 87) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 87))))  severity failure;
    assert RAM( 88) = std_logic_vector(to_unsigned(108 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 108 found " & integer'image(to_integer(unsigned(RAM( 88))))  severity failure;
    assert RAM( 89) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 89))))  severity failure;
    assert RAM( 90) = std_logic_vector(to_unsigned(180 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 180 found " & integer'image(to_integer(unsigned(RAM( 90))))  severity failure;
    assert RAM( 91) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM( 91))))  severity failure;


    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end tb_medium_len_arch;
