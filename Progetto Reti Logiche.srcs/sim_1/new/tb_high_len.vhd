library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_high_len is
end tb_high_len;

architecture tb_high_len_arch of tb_high_len is
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

signal RAM: ram_type := (  0 => std_logic_vector(to_unsigned(10  , 8)),
                           1 => std_logic_vector(to_unsigned(15  , 8)),
                           2 => std_logic_vector(to_unsigned(198 , 8)), -- Expected Output 152 -> 255
                           3 => std_logic_vector(to_unsigned(213 , 8)), -- Expected Output 153 -> 255
                           4 => std_logic_vector(to_unsigned(196 , 8)), -- Expected Output 154 -> 255
                           5 => std_logic_vector(to_unsigned( 87 , 8)), -- Expected Output 155 -> 170
                           6 => std_logic_vector(to_unsigned(166 , 8)), -- Expected Output 156 -> 255
                           7 => std_logic_vector(to_unsigned(238 , 8)), -- Expected Output 157 -> 255
                           8 => std_logic_vector(to_unsigned(  2 , 8)), -- Expected Output 158 ->   0
                           9 => std_logic_vector(to_unsigned(190 , 8)), -- Expected Output 159 -> 255
                          10 => std_logic_vector(to_unsigned(100 , 8)), -- Expected Output 160 -> 196
                          11 => std_logic_vector(to_unsigned(255 , 8)), -- Expected Output 161 -> 255
                          12 => std_logic_vector(to_unsigned(229 , 8)), -- Expected Output 162 -> 255
                          13 => std_logic_vector(to_unsigned( 19 , 8)), -- Expected Output 163 ->  34
                          14 => std_logic_vector(to_unsigned( 43 , 8)), -- Expected Output 164 ->  82
                          15 => std_logic_vector(to_unsigned( 90 , 8)), -- Expected Output 165 -> 176
                          16 => std_logic_vector(to_unsigned( 40 , 8)), -- Expected Output 166 ->  76
                          17 => std_logic_vector(to_unsigned(223 , 8)), -- Expected Output 167 -> 255
                          18 => std_logic_vector(to_unsigned( 51 , 8)), -- Expected Output 168 ->  98
                          19 => std_logic_vector(to_unsigned( 28 , 8)), -- Expected Output 169 ->  52
                          20 => std_logic_vector(to_unsigned( 20 , 8)), -- Expected Output 170 ->  36
                          21 => std_logic_vector(to_unsigned( 43 , 8)), -- Expected Output 171 ->  82
                          22 => std_logic_vector(to_unsigned( 75 , 8)), -- Expected Output 172 -> 146
                          23 => std_logic_vector(to_unsigned( 54 , 8)), -- Expected Output 173 -> 104
                          24 => std_logic_vector(to_unsigned(180 , 8)), -- Expected Output 174 -> 255
                          25 => std_logic_vector(to_unsigned( 96 , 8)), -- Expected Output 175 -> 188
                          26 => std_logic_vector(to_unsigned(213 , 8)), -- Expected Output 176 -> 255
                          27 => std_logic_vector(to_unsigned(238 , 8)), -- Expected Output 177 -> 255
                          28 => std_logic_vector(to_unsigned(195 , 8)), -- Expected Output 178 -> 255
                          29 => std_logic_vector(to_unsigned(180 , 8)), -- Expected Output 179 -> 255
                          30 => std_logic_vector(to_unsigned(110 , 8)), -- Expected Output 180 -> 216
                          31 => std_logic_vector(to_unsigned( 53 , 8)), -- Expected Output 181 -> 102
                          32 => std_logic_vector(to_unsigned(161 , 8)), -- Expected Output 182 -> 255
                          33 => std_logic_vector(to_unsigned(144 , 8)), -- Expected Output 183 -> 255
                          34 => std_logic_vector(to_unsigned(202 , 8)), -- Expected Output 184 -> 255
                          35 => std_logic_vector(to_unsigned( 28 , 8)), -- Expected Output 185 ->  52
                          36 => std_logic_vector(to_unsigned( 33 , 8)), -- Expected Output 186 ->  62
                          37 => std_logic_vector(to_unsigned( 95 , 8)), -- Expected Output 187 -> 186
                          38 => std_logic_vector(to_unsigned( 93 , 8)), -- Expected Output 188 -> 182
                          39 => std_logic_vector(to_unsigned(246 , 8)), -- Expected Output 189 -> 255
                          40 => std_logic_vector(to_unsigned( 88 , 8)), -- Expected Output 190 -> 172
                          41 => std_logic_vector(to_unsigned(122 , 8)), -- Expected Output 191 -> 240
                          42 => std_logic_vector(to_unsigned( 80 , 8)), -- Expected Output 192 -> 156
                          43 => std_logic_vector(to_unsigned(216 , 8)), -- Expected Output 193 -> 255
                          44 => std_logic_vector(to_unsigned( 21 , 8)), -- Expected Output 194 ->  38
                          45 => std_logic_vector(to_unsigned( 49 , 8)), -- Expected Output 195 ->  94
                          46 => std_logic_vector(to_unsigned(215 , 8)), -- Expected Output 196 -> 255
                          47 => std_logic_vector(to_unsigned(151 , 8)), -- Expected Output 197 -> 255
                          48 => std_logic_vector(to_unsigned(  9 , 8)), -- Expected Output 198 ->  14
                          49 => std_logic_vector(to_unsigned( 33 , 8)), -- Expected Output 199 ->  62
                          50 => std_logic_vector(to_unsigned(226 , 8)), -- Expected Output 200 -> 255
                          51 => std_logic_vector(to_unsigned(183 , 8)), -- Expected Output 201 -> 255
                          52 => std_logic_vector(to_unsigned( 19 , 8)), -- Expected Output 202 ->  34
                          53 => std_logic_vector(to_unsigned(148 , 8)), -- Expected Output 203 -> 255
                          54 => std_logic_vector(to_unsigned(153 , 8)), -- Expected Output 204 -> 255
                          55 => std_logic_vector(to_unsigned( 39 , 8)), -- Expected Output 205 ->  74
                          56 => std_logic_vector(to_unsigned( 90 , 8)), -- Expected Output 206 -> 176
                          57 => std_logic_vector(to_unsigned(252 , 8)), -- Expected Output 207 -> 255
                          58 => std_logic_vector(to_unsigned(112 , 8)), -- Expected Output 208 -> 220
                          59 => std_logic_vector(to_unsigned(235 , 8)), -- Expected Output 209 -> 255
                          60 => std_logic_vector(to_unsigned(116 , 8)), -- Expected Output 210 -> 228
                          61 => std_logic_vector(to_unsigned( 88 , 8)), -- Expected Output 211 -> 172
                          62 => std_logic_vector(to_unsigned(215 , 8)), -- Expected Output 212 -> 255
                          63 => std_logic_vector(to_unsigned(241 , 8)), -- Expected Output 213 -> 255
                          64 => std_logic_vector(to_unsigned(213 , 8)), -- Expected Output 214 -> 255
                          65 => std_logic_vector(to_unsigned(241 , 8)), -- Expected Output 215 -> 255
                          66 => std_logic_vector(to_unsigned(248 , 8)), -- Expected Output 216 -> 255
                          67 => std_logic_vector(to_unsigned(186 , 8)), -- Expected Output 217 -> 255
                          68 => std_logic_vector(to_unsigned(133 , 8)), -- Expected Output 218 -> 255
                          69 => std_logic_vector(to_unsigned(119 , 8)), -- Expected Output 219 -> 234
                          70 => std_logic_vector(to_unsigned( 87 , 8)), -- Expected Output 220 -> 170
                          71 => std_logic_vector(to_unsigned(183 , 8)), -- Expected Output 221 -> 255
                          72 => std_logic_vector(to_unsigned(109 , 8)), -- Expected Output 222 -> 214
                          73 => std_logic_vector(to_unsigned(243 , 8)), -- Expected Output 223 -> 255
                          74 => std_logic_vector(to_unsigned(  2 , 8)), -- Expected Output 224 ->   0
                          75 => std_logic_vector(to_unsigned(221 , 8)), -- Expected Output 225 -> 255
                          76 => std_logic_vector(to_unsigned( 19 , 8)), -- Expected Output 226 ->  34
                          77 => std_logic_vector(to_unsigned( 10 , 8)), -- Expected Output 227 ->  16
                          78 => std_logic_vector(to_unsigned(128 , 8)), -- Expected Output 228 -> 252
                          79 => std_logic_vector(to_unsigned(113 , 8)), -- Expected Output 229 -> 222
                          80 => std_logic_vector(to_unsigned( 98 , 8)), -- Expected Output 230 -> 192
                          81 => std_logic_vector(to_unsigned(190 , 8)), -- Expected Output 231 -> 255
                          82 => std_logic_vector(to_unsigned(180 , 8)), -- Expected Output 232 -> 255
                          83 => std_logic_vector(to_unsigned(109 , 8)), -- Expected Output 233 -> 214
                          84 => std_logic_vector(to_unsigned(147 , 8)), -- Expected Output 234 -> 255
                          85 => std_logic_vector(to_unsigned(152 , 8)), -- Expected Output 235 -> 255
                          86 => std_logic_vector(to_unsigned(156 , 8)), -- Expected Output 236 -> 255
                          87 => std_logic_vector(to_unsigned( 25 , 8)), -- Expected Output 237 ->  46
                          88 => std_logic_vector(to_unsigned( 90 , 8)), -- Expected Output 238 -> 176
                          89 => std_logic_vector(to_unsigned( 61 , 8)), -- Expected Output 239 -> 118
                          90 => std_logic_vector(to_unsigned(147 , 8)), -- Expected Output 240 -> 255
                          91 => std_logic_vector(to_unsigned(132 , 8)), -- Expected Output 241 -> 255
                          92 => std_logic_vector(to_unsigned( 20 , 8)), -- Expected Output 242 ->  36
                          93 => std_logic_vector(to_unsigned(121 , 8)), -- Expected Output 243 -> 238
                          94 => std_logic_vector(to_unsigned(159 , 8)), -- Expected Output 244 -> 255
                          95 => std_logic_vector(to_unsigned( 64 , 8)), -- Expected Output 245 -> 124
                          96 => std_logic_vector(to_unsigned( 55 , 8)), -- Expected Output 246 -> 106
                          97 => std_logic_vector(to_unsigned( 36 , 8)), -- Expected Output 247 ->  68
                          98 => std_logic_vector(to_unsigned(244 , 8)), -- Expected Output 248 -> 255
                          99 => std_logic_vector(to_unsigned( 58 , 8)), -- Expected Output 249 -> 112
                         100 => std_logic_vector(to_unsigned(120 , 8)), -- Expected Output 250 -> 236
                         101 => std_logic_vector(to_unsigned( 97 , 8)), -- Expected Output 251 -> 190
                         102 => std_logic_vector(to_unsigned(218 , 8)), -- Expected Output 252 -> 255
                         103 => std_logic_vector(to_unsigned(248 , 8)), -- Expected Output 253 -> 255
                         104 => std_logic_vector(to_unsigned(171 , 8)), -- Expected Output 254 -> 255
                         105 => std_logic_vector(to_unsigned( 96 , 8)), -- Expected Output 255 -> 188
                         106 => std_logic_vector(to_unsigned( 32 , 8)), -- Expected Output 256 ->  60
                         107 => std_logic_vector(to_unsigned(149 , 8)), -- Expected Output 257 -> 255
                         108 => std_logic_vector(to_unsigned(253 , 8)), -- Expected Output 258 -> 255
                         109 => std_logic_vector(to_unsigned(  2 , 8)), -- Expected Output 259 ->   0
                         110 => std_logic_vector(to_unsigned( 30 , 8)), -- Expected Output 260 ->  56
                         111 => std_logic_vector(to_unsigned(194 , 8)), -- Expected Output 261 -> 255
                         112 => std_logic_vector(to_unsigned(243 , 8)), -- Expected Output 262 -> 255
                         113 => std_logic_vector(to_unsigned(193 , 8)), -- Expected Output 263 -> 255
                         114 => std_logic_vector(to_unsigned(151 , 8)), -- Expected Output 264 -> 255
                         115 => std_logic_vector(to_unsigned( 18 , 8)), -- Expected Output 265 ->  32
                         116 => std_logic_vector(to_unsigned(115 , 8)), -- Expected Output 266 -> 226
                         117 => std_logic_vector(to_unsigned( 34 , 8)), -- Expected Output 267 ->  64
                         118 => std_logic_vector(to_unsigned( 11 , 8)), -- Expected Output 268 ->  18
                         119 => std_logic_vector(to_unsigned( 41 , 8)), -- Expected Output 269 ->  78
                         120 => std_logic_vector(to_unsigned( 96 , 8)), -- Expected Output 270 -> 188
                         121 => std_logic_vector(to_unsigned(255 , 8)), -- Expected Output 271 -> 255
                         122 => std_logic_vector(to_unsigned(139 , 8)), -- Expected Output 272 -> 255
                         123 => std_logic_vector(to_unsigned( 90 , 8)), -- Expected Output 273 -> 176
                         124 => std_logic_vector(to_unsigned( 83 , 8)), -- Expected Output 274 -> 162
                         125 => std_logic_vector(to_unsigned(107 , 8)), -- Expected Output 275 -> 210
                         126 => std_logic_vector(to_unsigned(176 , 8)), -- Expected Output 276 -> 255
                         127 => std_logic_vector(to_unsigned( 14 , 8)), -- Expected Output 277 ->  24
                         128 => std_logic_vector(to_unsigned( 73 , 8)), -- Expected Output 278 -> 142
                         129 => std_logic_vector(to_unsigned(181 , 8)), -- Expected Output 279 -> 255
                         130 => std_logic_vector(to_unsigned(  2 , 8)), -- Expected Output 280 ->   0
                         131 => std_logic_vector(to_unsigned(173 , 8)), -- Expected Output 281 -> 255
                         132 => std_logic_vector(to_unsigned( 30 , 8)), -- Expected Output 282 ->  56
                         133 => std_logic_vector(to_unsigned(  7 , 8)), -- Expected Output 283 ->  10
                         134 => std_logic_vector(to_unsigned( 58 , 8)), -- Expected Output 284 -> 112
                         135 => std_logic_vector(to_unsigned(202 , 8)), -- Expected Output 285 -> 255
                         136 => std_logic_vector(to_unsigned( 19 , 8)), -- Expected Output 286 ->  34
                         137 => std_logic_vector(to_unsigned(201 , 8)), -- Expected Output 287 -> 255
                         138 => std_logic_vector(to_unsigned( 90 , 8)), -- Expected Output 288 -> 176
                         139 => std_logic_vector(to_unsigned( 55 , 8)), -- Expected Output 289 -> 106
                         140 => std_logic_vector(to_unsigned(  4 , 8)), -- Expected Output 290 ->   4
                         141 => std_logic_vector(to_unsigned(208 , 8)), -- Expected Output 291 -> 255
                         142 => std_logic_vector(to_unsigned(  6 , 8)), -- Expected Output 292 ->   8
                         143 => std_logic_vector(to_unsigned(215 , 8)), -- Expected Output 293 -> 255
                         144 => std_logic_vector(to_unsigned(218 , 8)), -- Expected Output 294 -> 255
                         145 => std_logic_vector(to_unsigned(176 , 8)), -- Expected Output 295 -> 255
                         146 => std_logic_vector(to_unsigned(  9 , 8)), -- Expected Output 296 ->  14
                         147 => std_logic_vector(to_unsigned(182 , 8)), -- Expected Output 297 -> 255
                         148 => std_logic_vector(to_unsigned(214 , 8)), -- Expected Output 298 -> 255
                         149 => std_logic_vector(to_unsigned(155 , 8)), -- Expected Output 299 -> 255
                         150 => std_logic_vector(to_unsigned( 69 , 8)), -- Expected Output 300 -> 134
                         151 => std_logic_vector(to_unsigned(136 , 8)), -- Expected Output 301 -> 255
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

    -- Immagine originale = [ 198, 213, 196, 87, 166, 238, 2, 190, 100, 255, 229, 19, 43, 90, 40, 223, 51, 28, 20, 43, 75, 54, 180, 96, 213, 238, 195, 180, 110, 53, 161, 144, 202, 28, 33, 95, 93, 246, 88, 122, 80, 216, 21, 49, 215, 151, 9, 33, 226, 183, 19, 148, 153, 39, 90, 252, 112, 235, 116, 88, 215, 241, 213, 241, 248, 186, 133, 119, 87, 183, 109, 243, 2, 221, 19, 10, 128, 113, 98, 190, 180, 109, 147, 152, 156, 25, 90, 61, 147, 132, 20, 121, 159, 64, 55, 36, 244, 58, 120, 97, 218, 248, 171, 96, 32, 149, 253, 2, 30, 194, 243, 193, 151, 18, 115, 34, 11, 41, 96, 255, 139, 90, 83, 107, 176, 14, 73, 181, 2, 173, 30, 7, 58, 202, 19, 201, 90, 55, 4, 208, 6, 215, 218, 176, 9, 182, 214, 155, 69, 136, ]
    -- Immagine di output = [ 255, 255, 255, 170, 255, 255, 0, 255, 196, 255, 255, 34, 82, 176, 76, 255, 98, 52, 36, 82, 146, 104, 255, 188, 255, 255, 255, 255, 216, 102, 255, 255, 255, 52, 62, 186, 182, 255, 172, 240, 156, 255, 38, 94, 255, 255, 14, 62, 255, 255, 34, 255, 255, 74, 176, 255, 220, 255, 228, 172, 255, 255, 255, 255, 255, 255, 255, 234, 170, 255, 214, 255, 0, 255, 34, 16, 252, 222, 192, 255, 255, 214, 255, 255, 255, 46, 176, 118, 255, 255, 36, 238, 255, 124, 106, 68, 255, 112, 236, 190, 255, 255, 255, 188, 60, 255, 255, 0, 56, 255, 255, 255, 255, 32, 226, 64, 18, 78, 188, 255, 255, 176, 162, 210, 255, 24, 142, 255, 0, 255, 56, 10, 112, 255, 34, 255, 176, 106, 4, 255, 8, 255, 255, 255, 14, 255, 255, 255, 134, 255, ]
    assert RAM(152) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(152))))  severity failure;
    assert RAM(153) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(153))))  severity failure;
    assert RAM(154) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(154))))  severity failure;
    assert RAM(155) = std_logic_vector(to_unsigned(170 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 170 found " & integer'image(to_integer(unsigned(RAM(155))))  severity failure;
    assert RAM(156) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(156))))  severity failure;
    assert RAM(157) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(157))))  severity failure;
    assert RAM(158) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM(158))))  severity failure;
    assert RAM(159) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(159))))  severity failure;
    assert RAM(160) = std_logic_vector(to_unsigned(196 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 196 found " & integer'image(to_integer(unsigned(RAM(160))))  severity failure;
    assert RAM(161) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(161))))  severity failure;
    assert RAM(162) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(162))))  severity failure;
    assert RAM(163) = std_logic_vector(to_unsigned( 34 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  34 found " & integer'image(to_integer(unsigned(RAM(163))))  severity failure;
    assert RAM(164) = std_logic_vector(to_unsigned( 82 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  82 found " & integer'image(to_integer(unsigned(RAM(164))))  severity failure;
    assert RAM(165) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM(165))))  severity failure;
    assert RAM(166) = std_logic_vector(to_unsigned( 76 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  76 found " & integer'image(to_integer(unsigned(RAM(166))))  severity failure;
    assert RAM(167) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(167))))  severity failure;
    assert RAM(168) = std_logic_vector(to_unsigned( 98 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  98 found " & integer'image(to_integer(unsigned(RAM(168))))  severity failure;
    assert RAM(169) = std_logic_vector(to_unsigned( 52 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  52 found " & integer'image(to_integer(unsigned(RAM(169))))  severity failure;
    assert RAM(170) = std_logic_vector(to_unsigned( 36 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  36 found " & integer'image(to_integer(unsigned(RAM(170))))  severity failure;
    assert RAM(171) = std_logic_vector(to_unsigned( 82 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  82 found " & integer'image(to_integer(unsigned(RAM(171))))  severity failure;
    assert RAM(172) = std_logic_vector(to_unsigned(146 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 146 found " & integer'image(to_integer(unsigned(RAM(172))))  severity failure;
    assert RAM(173) = std_logic_vector(to_unsigned(104 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 104 found " & integer'image(to_integer(unsigned(RAM(173))))  severity failure;
    assert RAM(174) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(174))))  severity failure;
    assert RAM(175) = std_logic_vector(to_unsigned(188 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 188 found " & integer'image(to_integer(unsigned(RAM(175))))  severity failure;
    assert RAM(176) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(176))))  severity failure;
    assert RAM(177) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(177))))  severity failure;
    assert RAM(178) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(178))))  severity failure;
    assert RAM(179) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(179))))  severity failure;
    assert RAM(180) = std_logic_vector(to_unsigned(216 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 216 found " & integer'image(to_integer(unsigned(RAM(180))))  severity failure;
    assert RAM(181) = std_logic_vector(to_unsigned(102 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 102 found " & integer'image(to_integer(unsigned(RAM(181))))  severity failure;
    assert RAM(182) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(182))))  severity failure;
    assert RAM(183) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(183))))  severity failure;
    assert RAM(184) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(184))))  severity failure;
    assert RAM(185) = std_logic_vector(to_unsigned( 52 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  52 found " & integer'image(to_integer(unsigned(RAM(185))))  severity failure;
    assert RAM(186) = std_logic_vector(to_unsigned( 62 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  62 found " & integer'image(to_integer(unsigned(RAM(186))))  severity failure;
    assert RAM(187) = std_logic_vector(to_unsigned(186 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 186 found " & integer'image(to_integer(unsigned(RAM(187))))  severity failure;
    assert RAM(188) = std_logic_vector(to_unsigned(182 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 182 found " & integer'image(to_integer(unsigned(RAM(188))))  severity failure;
    assert RAM(189) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(189))))  severity failure;
    assert RAM(190) = std_logic_vector(to_unsigned(172 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 172 found " & integer'image(to_integer(unsigned(RAM(190))))  severity failure;
    assert RAM(191) = std_logic_vector(to_unsigned(240 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 240 found " & integer'image(to_integer(unsigned(RAM(191))))  severity failure;
    assert RAM(192) = std_logic_vector(to_unsigned(156 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 156 found " & integer'image(to_integer(unsigned(RAM(192))))  severity failure;
    assert RAM(193) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(193))))  severity failure;
    assert RAM(194) = std_logic_vector(to_unsigned( 38 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  38 found " & integer'image(to_integer(unsigned(RAM(194))))  severity failure;
    assert RAM(195) = std_logic_vector(to_unsigned( 94 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  94 found " & integer'image(to_integer(unsigned(RAM(195))))  severity failure;
    assert RAM(196) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(196))))  severity failure;
    assert RAM(197) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(197))))  severity failure;
    assert RAM(198) = std_logic_vector(to_unsigned( 14 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  14 found " & integer'image(to_integer(unsigned(RAM(198))))  severity failure;
    assert RAM(199) = std_logic_vector(to_unsigned( 62 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  62 found " & integer'image(to_integer(unsigned(RAM(199))))  severity failure;
    assert RAM(200) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(200))))  severity failure;
    assert RAM(201) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(201))))  severity failure;
    assert RAM(202) = std_logic_vector(to_unsigned( 34 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  34 found " & integer'image(to_integer(unsigned(RAM(202))))  severity failure;
    assert RAM(203) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(203))))  severity failure;
    assert RAM(204) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(204))))  severity failure;
    assert RAM(205) = std_logic_vector(to_unsigned( 74 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  74 found " & integer'image(to_integer(unsigned(RAM(205))))  severity failure;
    assert RAM(206) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM(206))))  severity failure;
    assert RAM(207) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(207))))  severity failure;
    assert RAM(208) = std_logic_vector(to_unsigned(220 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 220 found " & integer'image(to_integer(unsigned(RAM(208))))  severity failure;
    assert RAM(209) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(209))))  severity failure;
    assert RAM(210) = std_logic_vector(to_unsigned(228 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 228 found " & integer'image(to_integer(unsigned(RAM(210))))  severity failure;
    assert RAM(211) = std_logic_vector(to_unsigned(172 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 172 found " & integer'image(to_integer(unsigned(RAM(211))))  severity failure;
    assert RAM(212) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(212))))  severity failure;
    assert RAM(213) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(213))))  severity failure;
    assert RAM(214) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(214))))  severity failure;
    assert RAM(215) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(215))))  severity failure;
    assert RAM(216) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(216))))  severity failure;
    assert RAM(217) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(217))))  severity failure;
    assert RAM(218) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(218))))  severity failure;
    assert RAM(219) = std_logic_vector(to_unsigned(234 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 234 found " & integer'image(to_integer(unsigned(RAM(219))))  severity failure;
    assert RAM(220) = std_logic_vector(to_unsigned(170 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 170 found " & integer'image(to_integer(unsigned(RAM(220))))  severity failure;
    assert RAM(221) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(221))))  severity failure;
    assert RAM(222) = std_logic_vector(to_unsigned(214 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 214 found " & integer'image(to_integer(unsigned(RAM(222))))  severity failure;
    assert RAM(223) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(223))))  severity failure;
    assert RAM(224) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM(224))))  severity failure;
    assert RAM(225) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(225))))  severity failure;
    assert RAM(226) = std_logic_vector(to_unsigned( 34 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  34 found " & integer'image(to_integer(unsigned(RAM(226))))  severity failure;
    assert RAM(227) = std_logic_vector(to_unsigned( 16 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  16 found " & integer'image(to_integer(unsigned(RAM(227))))  severity failure;
    assert RAM(228) = std_logic_vector(to_unsigned(252 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 252 found " & integer'image(to_integer(unsigned(RAM(228))))  severity failure;
    assert RAM(229) = std_logic_vector(to_unsigned(222 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 222 found " & integer'image(to_integer(unsigned(RAM(229))))  severity failure;
    assert RAM(230) = std_logic_vector(to_unsigned(192 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 192 found " & integer'image(to_integer(unsigned(RAM(230))))  severity failure;
    assert RAM(231) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(231))))  severity failure;
    assert RAM(232) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(232))))  severity failure;
    assert RAM(233) = std_logic_vector(to_unsigned(214 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 214 found " & integer'image(to_integer(unsigned(RAM(233))))  severity failure;
    assert RAM(234) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(234))))  severity failure;
    assert RAM(235) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(235))))  severity failure;
    assert RAM(236) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(236))))  severity failure;
    assert RAM(237) = std_logic_vector(to_unsigned( 46 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  46 found " & integer'image(to_integer(unsigned(RAM(237))))  severity failure;
    assert RAM(238) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM(238))))  severity failure;
    assert RAM(239) = std_logic_vector(to_unsigned(118 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 118 found " & integer'image(to_integer(unsigned(RAM(239))))  severity failure;
    assert RAM(240) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(240))))  severity failure;
    assert RAM(241) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(241))))  severity failure;
    assert RAM(242) = std_logic_vector(to_unsigned( 36 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  36 found " & integer'image(to_integer(unsigned(RAM(242))))  severity failure;
    assert RAM(243) = std_logic_vector(to_unsigned(238 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 238 found " & integer'image(to_integer(unsigned(RAM(243))))  severity failure;
    assert RAM(244) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(244))))  severity failure;
    assert RAM(245) = std_logic_vector(to_unsigned(124 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 124 found " & integer'image(to_integer(unsigned(RAM(245))))  severity failure;
    assert RAM(246) = std_logic_vector(to_unsigned(106 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 106 found " & integer'image(to_integer(unsigned(RAM(246))))  severity failure;
    assert RAM(247) = std_logic_vector(to_unsigned( 68 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  68 found " & integer'image(to_integer(unsigned(RAM(247))))  severity failure;
    assert RAM(248) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(248))))  severity failure;
    assert RAM(249) = std_logic_vector(to_unsigned(112 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 112 found " & integer'image(to_integer(unsigned(RAM(249))))  severity failure;
    assert RAM(250) = std_logic_vector(to_unsigned(236 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 236 found " & integer'image(to_integer(unsigned(RAM(250))))  severity failure;
    assert RAM(251) = std_logic_vector(to_unsigned(190 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 190 found " & integer'image(to_integer(unsigned(RAM(251))))  severity failure;
    assert RAM(252) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(252))))  severity failure;
    assert RAM(253) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(253))))  severity failure;
    assert RAM(254) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(254))))  severity failure;
    assert RAM(255) = std_logic_vector(to_unsigned(188 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 188 found " & integer'image(to_integer(unsigned(RAM(255))))  severity failure;
    assert RAM(256) = std_logic_vector(to_unsigned( 60 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  60 found " & integer'image(to_integer(unsigned(RAM(256))))  severity failure;
    assert RAM(257) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(257))))  severity failure;
    assert RAM(258) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(258))))  severity failure;
    assert RAM(259) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM(259))))  severity failure;
    assert RAM(260) = std_logic_vector(to_unsigned( 56 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  56 found " & integer'image(to_integer(unsigned(RAM(260))))  severity failure;
    assert RAM(261) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(261))))  severity failure;
    assert RAM(262) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(262))))  severity failure;
    assert RAM(263) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(263))))  severity failure;
    assert RAM(264) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(264))))  severity failure;
    assert RAM(265) = std_logic_vector(to_unsigned( 32 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  32 found " & integer'image(to_integer(unsigned(RAM(265))))  severity failure;
    assert RAM(266) = std_logic_vector(to_unsigned(226 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 226 found " & integer'image(to_integer(unsigned(RAM(266))))  severity failure;
    assert RAM(267) = std_logic_vector(to_unsigned( 64 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  64 found " & integer'image(to_integer(unsigned(RAM(267))))  severity failure;
    assert RAM(268) = std_logic_vector(to_unsigned( 18 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  18 found " & integer'image(to_integer(unsigned(RAM(268))))  severity failure;
    assert RAM(269) = std_logic_vector(to_unsigned( 78 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  78 found " & integer'image(to_integer(unsigned(RAM(269))))  severity failure;
    assert RAM(270) = std_logic_vector(to_unsigned(188 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 188 found " & integer'image(to_integer(unsigned(RAM(270))))  severity failure;
    assert RAM(271) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(271))))  severity failure;
    assert RAM(272) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(272))))  severity failure;
    assert RAM(273) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM(273))))  severity failure;
    assert RAM(274) = std_logic_vector(to_unsigned(162 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 162 found " & integer'image(to_integer(unsigned(RAM(274))))  severity failure;
    assert RAM(275) = std_logic_vector(to_unsigned(210 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 210 found " & integer'image(to_integer(unsigned(RAM(275))))  severity failure;
    assert RAM(276) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(276))))  severity failure;
    assert RAM(277) = std_logic_vector(to_unsigned( 24 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  24 found " & integer'image(to_integer(unsigned(RAM(277))))  severity failure;
    assert RAM(278) = std_logic_vector(to_unsigned(142 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 142 found " & integer'image(to_integer(unsigned(RAM(278))))  severity failure;
    assert RAM(279) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(279))))  severity failure;
    assert RAM(280) = std_logic_vector(to_unsigned(  0 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   0 found " & integer'image(to_integer(unsigned(RAM(280))))  severity failure;
    assert RAM(281) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(281))))  severity failure;
    assert RAM(282) = std_logic_vector(to_unsigned( 56 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  56 found " & integer'image(to_integer(unsigned(RAM(282))))  severity failure;
    assert RAM(283) = std_logic_vector(to_unsigned( 10 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  10 found " & integer'image(to_integer(unsigned(RAM(283))))  severity failure;
    assert RAM(284) = std_logic_vector(to_unsigned(112 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 112 found " & integer'image(to_integer(unsigned(RAM(284))))  severity failure;
    assert RAM(285) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(285))))  severity failure;
    assert RAM(286) = std_logic_vector(to_unsigned( 34 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  34 found " & integer'image(to_integer(unsigned(RAM(286))))  severity failure;
    assert RAM(287) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(287))))  severity failure;
    assert RAM(288) = std_logic_vector(to_unsigned(176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 176 found " & integer'image(to_integer(unsigned(RAM(288))))  severity failure;
    assert RAM(289) = std_logic_vector(to_unsigned(106 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 106 found " & integer'image(to_integer(unsigned(RAM(289))))  severity failure;
    assert RAM(290) = std_logic_vector(to_unsigned(  4 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   4 found " & integer'image(to_integer(unsigned(RAM(290))))  severity failure;
    assert RAM(291) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(291))))  severity failure;
    assert RAM(292) = std_logic_vector(to_unsigned(  8 , 8)) report "TEST FALLITO (WORKING ZONE). Expected   8 found " & integer'image(to_integer(unsigned(RAM(292))))  severity failure;
    assert RAM(293) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(293))))  severity failure;
    assert RAM(294) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(294))))  severity failure;
    assert RAM(295) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(295))))  severity failure;
    assert RAM(296) = std_logic_vector(to_unsigned( 14 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  14 found " & integer'image(to_integer(unsigned(RAM(296))))  severity failure;
    assert RAM(297) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(297))))  severity failure;
    assert RAM(298) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(298))))  severity failure;
    assert RAM(299) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(299))))  severity failure;
    assert RAM(300) = std_logic_vector(to_unsigned(134 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 134 found " & integer'image(to_integer(unsigned(RAM(300))))  severity failure;
    assert RAM(301) = std_logic_vector(to_unsigned(255 , 8)) report "TEST FALLITO (WORKING ZONE). Expected 255 found " & integer'image(to_integer(unsigned(RAM(301))))  severity failure;


    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end tb_high_len_arch;
