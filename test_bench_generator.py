import os
from random import randint
from math import floor, log2

class Data():
    def __init__(self):
        self.pixel = randint(MIN_VALUE, MAX_VALUE)
        self.expected = 0

    def equilize(self):
        temp_pixel = (self.pixel - min_value) << shift
        self.expected = 255 if temp_pixel > 255 else temp_pixel

PATH = 'Progetto Reti Logiche/Progetto Reti Logiche.srcs/sim_1/new/'
MAX_VALUE = 255;
MIN_VALUE = 0;

def max(arr):
    m = arr[0].pixel
    l = len(arr)
    for i in range(l):
        if (arr[i].pixel > m):
            m = arr[i].pixel
    return m

def min(arr):
    m = arr[0].pixel
    l = len(arr)
    for i in range(l):
        if (arr[i].pixel < m):
            m = arr[i].pixel
    return m


tb_name = input('insert name of the test bench (without .vhd extension): ')
file_name = (PATH+tb_name+'.vhd')

n_col = int(input('type the number of columns of the test bench: '))
n_row = int(input('type the number of rows of the test bench: '))
image_dimensions = n_col * n_row;
data = []

for i in range(image_dimensions):
    data.append(Data())

max_value = max(data)
min_value = min(data)
delta = max_value - min_value
shift = (8 - floor(log2(delta + 1)))

# UNCOMMENT TO DEBUG
# print('min: ' + str(min_value))
# print('max: ' + str(max_value))
# print('shift: '+ str(shift))

for i in range(image_dimensions):
    data[i].equilize()


tb_code = '''library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ''' + str(tb_name) + ''' is
end ''' + str(tb_name) + ''';

architecture ''' + str(tb_name) + '''_arch of ''' + str(tb_name) + ''' is
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

signal RAM: ram_type := (  0 => std_logic_vector(to_unsigned(''' + str(n_col) + '''  , 8)),
                           1 => std_logic_vector(to_unsigned(''' + str(n_row) + '''  , 8)),\n'''

for i in range(image_dimensions):
    random_pixel = data[i].pixel
    expected_value = data[i].expected
    tb_code += '                         %3d => std_logic_vector(to_unsigned(%3d , 8)), -- Expected Output %3d -> %3d\n'%(i+2, random_pixel, i+2+image_dimensions, expected_value)


tb_code += '''                        others => (others =>'0'));
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

    -- Immagine originale = [ '''

for i in range(image_dimensions):
    tb_code += str(data[i].pixel) + ', '
tb_code += ']\n'

tb_code += '    -- Immagine di output = [ '

for i in range(image_dimensions):
    tb_code += str(data[i].expected) + ', '
tb_code += ']\n'

for i in range(image_dimensions):
    tb_code += '    assert RAM(%3d) = std_logic_vector(to_unsigned(%3d , 8)) report "TEST FALLITO (WORKING ZONE). Expected %3d found " '%(i+2+image_dimensions, data[i].expected, data[i].expected) + "& integer'image(to_integer(unsigned(RAM(%3d))))  severity failure;\n"%(i+2+image_dimensions)
tb_code += '''

    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end ''' + str(tb_name) + '''_arch;\n'''

with open(file_name, 'w') as fp:
    fp.write(tb_code)


print('Test bench created successfully, go to {} to open it'.format(file_name))
