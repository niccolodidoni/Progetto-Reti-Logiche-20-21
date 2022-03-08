-- clock period = 100ns
-- clock frequency = 10 MHz

------------------------------------------------------------- PROCESSING UNIT -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processing_unit is
    port (
        -- In (product)
        pu_i_rst            : in std_logic;
        pu_i_clk            : in std_logic;
        pu_i_data           : in std_logic_vector(7 downto 0);
        pu_col_load         : in std_logic;
        pu_row_load         : in std_logic;
        pu_row_sel          : in std_logic;
        pu_new_prod_sel     : in std_logic;
        pu_prod_load        : in std_logic;
        pu_prod_load_sel    : in std_logic;

        -- In (address)
        pu_addr_sel_start   : in std_logic;
        pu_ctrl_addr        : in std_logic_vector(15 downto 0);
        pu_ctrl_addr_sel    : in std_logic;
        pu_address_load     : in std_logic;
        pu_prev_addr_load   : in std_logic;

        -- In
        pu_first_addr_sel   : in std_logic;
        pu_first_addr_load  : in std_logic;
        pu_delta_value_load : in std_logic;
        pu_mem_addr_sel     : in std_logic;

        -- To Memory
        pu_o_data    : out std_logic_vector(7 downto 0);
        pu_o_address : out std_logic_vector(15 downto 0);

        -- To controller
        pu_proc_over : out std_logic;
        pu_calc_over : out std_logic;
        pu_zero_col  : out std_logic;
        pu_zero_row  : out std_logic
    );
 end processing_unit;

 architecture pu_arch of processing_unit is
    -- registers (outputs)
    signal pu_n_col_reg       : std_logic_vector(7 downto 0);  -- section 1
    signal pu_n_row_reg       : std_logic_vector(7 downto 0);  -- section 2
    signal pu_product_reg     : std_logic_vector(15 downto 0); -- section 3
    signal pu_mem_addr_reg    : std_logic_vector(15 downto 0); -- section 4
    signal pu_min_reg         : std_logic_vector(7 downto 0);  -- section 5
    signal pu_max_reg         : std_logic_vector(7 downto 0);  -- section 5
    signal pu_min_value_reg   : std_logic_vector(7 downto 0);  -- section 6
    signal pu_delta_value_reg : std_logic_vector(7 downto 0);  -- section 6


    -- internal control signals
    signal pu_calc_over_signal    : std_logic; -- section 2
    signal pu_internal_prod_load  : std_logic; -- section 3
    signal pu_min_load            : std_logic; -- section 5
    signal pu_max_load            : std_logic; -- section 5
    signal pu_new_pixel_value_sel : std_logic; -- section 6

    -- mux outputs
    signal pu_row_sel_mux        : std_logic_vector(7 downto 0);  -- section 2
    signal pu_new_prod           : std_logic_vector(15 downto 0); -- section 3
    signal pu_new_prev_addr      : std_logic_vector(15 downto 0); -- section 4
    signal pu_internal_o_address : std_logic_vector(15 downto 0); -- section 4

    -- comparator, sum and sub outputs
    signal pu_n_row_sub       : std_logic_vector(7 downto 0);  -- section 2
    signal pu_sum_to_prod     : std_logic_vector(15 downto 0); -- section 3
    signal pu_next_addr_sum   : std_logic_vector(15 downto 0); -- section 4
    signal pu_final_mem_addr  : std_logic_vector(15 downto 0); -- section 4
    signal pu_is_less_out     : std_logic;                     -- section 5
    signal pu_is_more_out     : std_logic;                     -- section 5
    signal pu_delta_value_sub : std_logic_vector(7 downto 0);  -- section 6
    signal pu_int_delta_value : integer;                       -- section 6
    signal pu_pixel_sub       : std_logic_vector(15 downto 0); -- section 6
    signal pu_shift_out       : std_logic_vector(15 downto 0); -- section 6



    begin
        -- START section 1
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_n_col_reg <= "00000000";
            elsif pu_i_clk'event and pu_i_clk = '1' then
                if pu_col_load = '1' then
                    pu_n_col_reg <= pu_i_data;
                end if;
            end if;
        end process;

        pu_zero_col <= '1' when pu_i_data = "00000000" else '0';

        -- END section 1


        -- START section 2
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_n_row_reg <= "00000000";
            elsif pu_i_clk'event and pu_i_clk = '1' then
                if pu_row_load = '1' then
                    pu_n_row_reg <= pu_row_sel_mux;
                end if;
            end if;
        end process;


        pu_calc_over_signal <= '1' when pu_n_row_reg = "00000000" else '0';
        pu_calc_over <= pu_calc_over_signal;
        pu_n_row_sub <= pu_n_row_reg - "00000001";
        pu_zero_row <= '1' when pu_i_data = "00000000" else '0';

        with pu_row_sel select
            pu_row_sel_mux <= pu_i_data     when '1',
                              pu_n_row_sub  when '0',
                              "XXXXXXXX" when others;

        -- END section


        -- START section 3
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_product_reg <= "0000000000000001";
            elsif pu_i_clk'event and pu_i_clk = '1' then
                 if pu_internal_prod_load = '1' then
                    pu_product_reg <= pu_new_prod;
                    -- pu_product_reg <= pu_sum_to_prod;
                 end if;
            end if;
        end process;

        pu_internal_prod_load <= not pu_calc_over_signal when pu_prod_load_sel = '0' else pu_prod_load;
        pu_new_prod           <= "0000000000000001" when pu_new_prod_sel = '1' else pu_sum_to_prod;
        pu_sum_to_prod        <= pu_product_reg + pu_n_col_reg;
        pu_proc_over          <= '1' when pu_product_reg = pu_mem_addr_reg else '0';
        -- END section 3


        -- START section 4
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_mem_addr_reg  <= "0000000000000010";
            elsif pu_i_clk'event AND pu_i_clk = '1' then
                if pu_address_load = '1' then
                    pu_mem_addr_reg <= pu_next_addr_sum;
                end if;
            end if;
        end process;

        pu_new_prev_addr      <= "0000000000000001" when pu_addr_sel_start = '1' else pu_mem_addr_reg;
        pu_next_addr_sum      <= pu_new_prev_addr + "0000000000000001";
        pu_internal_o_address <= pu_ctrl_addr when pu_ctrl_addr_sel = '1' else pu_final_mem_addr;
        pu_o_address          <= pu_internal_o_address;
        pu_final_mem_addr     <= pu_mem_addr_reg + pu_product_reg - "0000000000000001" when pu_mem_addr_sel = '1' else pu_mem_addr_reg;

        -- END section 4


        -- START section 5
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_min_reg <= "00000000";
                pu_max_reg <= "00000000";
            elsif pu_i_clk'event AND pu_i_clk = '1' then
                if pu_min_load = '1' then
                    pu_min_reg <= pu_i_data;
                end if;
                if pu_max_load = '1' then
                    pu_max_reg <= pu_i_data;
                end if;
            end if;
        end process;

        pu_is_less_out     <= '1' when pu_i_data < pu_min_reg else '0';
        pu_min_load        <= pu_is_less_out when pu_first_addr_sel = '0' else pu_first_addr_load;
        pu_is_more_out     <= '1' when pu_i_data > pu_max_reg else '0';
        pu_max_load        <= pu_is_more_out when pu_first_addr_sel = '0' else pu_first_addr_load;
        pu_delta_value_sub <= pu_max_reg - pu_min_reg;

        -- END section 5


        -- START section 6
        process(pu_i_clk, pu_i_rst)
        begin
            if pu_i_rst = '1' then
                pu_min_value_reg   <= "00000000";
                pu_delta_value_reg <= "00000000";
            elsif pu_i_clk'event and pu_i_clk = '1' then
                if pu_delta_value_load = '1' then
                    pu_min_value_reg   <= pu_min_reg;
                    pu_delta_value_reg <= pu_delta_value_sub;
                end if;
            end if;
        end process;

        pu_pixel_sub       <= ("00000000" & pu_i_data) - pu_min_value_reg;
        pu_int_delta_value <= TO_INTEGER(unsigned(pu_delta_value_reg));

        pu_shift_out <= pu_pixel_sub(8  downto 0) & "0000000" when pu_int_delta_value >= 1   AND pu_int_delta_value <= 2   else
                        pu_pixel_sub(9  downto 0) &  "000000" when pu_int_delta_value >= 3   AND pu_int_delta_value <= 6   else
                        pu_pixel_sub(10 downto 0) &   "00000" when pu_int_delta_value >= 7   AND pu_int_delta_value <= 14  else
                        pu_pixel_sub(11 downto 0) &    "0000" when pu_int_delta_value >= 15  AND pu_int_delta_value <= 30  else
                        pu_pixel_sub(12 downto 0) &     "000" when pu_int_delta_value >= 31  AND pu_int_delta_value <= 62  else
                        pu_pixel_sub(13 downto 0) &      "00" when pu_int_delta_value >= 63  AND pu_int_delta_value <= 126 else
                        pu_pixel_sub(14 downto 0) &       "0" when pu_int_delta_value >= 127 AND pu_int_delta_value <= 254 else
                        pu_pixel_sub(15 downto 0)             when pu_int_delta_value = 255
                        else "0000000000000000";

        pu_new_pixel_value_sel <= '1' when pu_shift_out(15 downto 8) = "00000000" else '0';
        pu_o_data <= pu_shift_out(7 downto 0) when pu_new_pixel_value_sel = '1' else "11111111";

        -- END section 6

 end pu_arch;

 ----------------------------------------------------------- FINITE STATE MACHINE ----------------------------------------------------------------------------
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.NUMERIC_STD.ALL;

 entity finite_state_machine is
   port (
     -- output signals
     fsm_col_load      : out std_logic;
     fsm_row_load      : out std_logic;
     fsm_row_sel       : out std_logic;
     fsm_new_prod_sel  : out std_logic;
     fsm_prod_load     : out std_logic;
     fsm_prod_load_sel : out std_logic;

     fsm_addr_sel_start : out std_logic;
     fsm_ctrl_addr      : out std_logic_vector(15 downto 0);
     fsm_ctrl_addr_sel  : out std_logic;
     fsm_address_load   : out std_logic;
     fsm_prev_addr_load : out std_logic;

     fsm_first_addr_sel   : out std_logic;
     fsm_first_addr_load  : out std_logic;
     fsm_delta_value_load : out std_logic;
     fsm_mem_addr_sel     : out std_logic;

     fsm_o_en   : out std_logic;
     fsm_o_we   : out std_logic;
     fsm_o_done : out std_logic;

     -- input signals
     fsm_i_clk         : in std_logic;
     fsm_i_rst         : in std_logic;
     fsm_i_start       : in std_logic;
     fsm_proc_over     : in std_logic;
     fsm_calc_over     : in std_logic;
     fsm_zero_col      : in std_logic;
     fsm_zero_row      : in std_logic
   );
 end finite_state_machine;


 architecture arch_finite_state_machine of finite_state_machine is

   -- new signals definition
   type STATE is ( IDLE,
                   COL_FETCH,
                   COL_SAVE,
                   ROW_FETCH,
                   ROW_SAVE,
                   PRODUCT_PROCESSING,
                   FIRST_VALUE_ASK,
                   FIRST_VALUE_WAIT,
                   MAX_MIN_CALC,
                   MAX_MIN_SAVE,
                   START_EQ,          
                   MEM_ADDR,
                   SAVE_TO_MEM,
                   FINAL,
                   ERROR);                   
   signal current_state, next_state: STATE;

   begin


     -- NEXT STATE
     NEXT_STATE_ASSIGNMENT: process(fsm_i_clk, fsm_i_rst)
     begin
         if fsm_i_rst = '1' then
             current_state <= IDLE;
         elsif fsm_i_clk'event AND fsm_i_clk = '1' then
             current_state <= next_state;
         end if;
     end process NEXT_STATE_ASSIGNMENT;


     NEXT_STATE_PROCESSING: process(current_state, fsm_calc_over, fsm_zero_col, fsm_zero_row, fsm_i_start)
     begin
         next_state <= current_state;
         case current_state is
             when IDLE =>
                 if fsm_i_start = '1' then
                     next_state <= COL_FETCH;
                 -- elsif fsm_i_start = '0' then gestito dal primo statement del process
                 end if;
             when COL_FETCH =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= COL_SAVE;
                 end if;
             when COL_SAVE =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_zero_col = '0' then
                     next_state <= ROW_FETCH;
                 elsif fsm_zero_col = '1' then
                     next_state <= FINAL;
                 end if;
             when ROW_FETCH =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= ROW_SAVE;
                 end if;
             when ROW_SAVE =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_zero_row = '0' then
                     next_state <= PRODUCT_PROCESSING;
                 elsif fsm_zero_row = '1' then
                     next_state <= FINAL;
                 end if;
             when PRODUCT_PROCESSING =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_calc_over = '1' then
                     next_state <= FIRST_VALUE_ASK;
                 -- elsif fsm_calc_over = '1' gestito dal primo statement del process
                 end if;
             when FIRST_VALUE_ASK =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= FIRST_VALUE_WAIT;
                 end if;
             when FIRST_VALUE_WAIT =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_proc_over = '1' then
                     next_state <= START_EQ;
                 else
                     next_state <= MAX_MIN_SAVE;
                 end if;
             when MAX_MIN_SAVE =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= MAX_MIN_CALC;
                 end if;
             when MAX_MIN_CALC =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_proc_over = '0' then
                     next_state <= MAX_MIN_SAVE;
                 elsif fsm_proc_over = '1' then
                     next_state <= START_EQ;
                 end if;
             when START_EQ =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= SAVE_TO_MEM;
                 end if;
             when MEM_ADDR =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 elsif fsm_proc_over = '1' then
                     next_state <= FINAL;
                 elsif fsm_proc_over = '0' then
                     next_state <= SAVE_TO_MEM;
                 end if;
             when SAVE_TO_MEM =>
                 if fsm_i_start = '0' then
                     next_state <= ERROR;
                 else
                     next_state <= MEM_ADDR;
                 end if;
             when FINAL =>
                 if fsm_i_start = '0' then
                     next_state <= IDLE;
                 -- elsif fsm_i_start = '1' gestito dal primo statement del process
                 end if;
             when ERROR =>  -- si puo' uscire da questo stato solo se il segnale fsm_i_rst vale 1 (caso gestito dal processo NEXT_STATE_ASSIGNMENT)
         end case;
     end process NEXT_STATE_PROCESSING;



     -- SIGNALS CONTROL
     SIGNALS_PROCESS: process(current_state)
     begin
         -- remember to assign all signal by defalut
         fsm_col_load         <= '0';
         fsm_row_load         <= '0';
         fsm_row_sel          <= '0';
         fsm_new_prod_sel     <= '0';
         fsm_prod_load        <= '0';
         fsm_prod_load_sel    <= '0';
         fsm_addr_sel_start   <= '0';
         fsm_ctrl_addr        <= "0000000000000000";
         fsm_ctrl_addr_sel    <= '0';
         fsm_address_load     <= '0';
         fsm_prev_addr_load   <= '0';
         fsm_first_addr_sel   <= '0';
         fsm_first_addr_load  <= '0';
         fsm_delta_value_load <= '0';
         fsm_mem_addr_sel     <= '0';
         fsm_o_en             <= '0';
         fsm_o_we             <= '0';
         fsm_o_done           <= '0';
         

         case current_state is
             when IDLE =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '1';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '1';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '1';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when COL_FETCH =>
                 fsm_col_load         <= '1';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= '0';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '1';
                 fsm_ctrl_addr        <= "0000000000000000";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '1';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when COL_SAVE =>
                 fsm_col_load         <= '1';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= '0';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= 'X';
                 fsm_ctrl_addr        <= "0000000000000001";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when ROW_FETCH =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '1';
                 fsm_row_sel          <= '1';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= 'X';
                 fsm_ctrl_addr        <= "0000000000000001";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when ROW_SAVE =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '1';
                 fsm_row_sel          <= '1';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= 'X';
                 fsm_ctrl_addr        <= "0000000000000001";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when PRODUCT_PROCESSING =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '1';
                 fsm_row_sel          <= '0';
                 fsm_new_prod_sel     <= '0';
                 fsm_prod_load        <= 'X';
                 fsm_prod_load_sel    <= '0';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '0';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when FIRST_VALUE_ASK =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "0000000000000010";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '1';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
               when FIRST_VALUE_WAIT =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "0000000000000010";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '1';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '1';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when MAX_MIN_CALC =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '0';
                 fsm_address_load     <= '1';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '0';
                 fsm_first_addr_load  <= 'X';
                 fsm_delta_value_load <= '1';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when MAX_MIN_SAVE =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '0';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '1';
                 fsm_first_addr_sel   <= '0';
                 fsm_first_addr_load  <= 'X';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when START_EQ =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '1';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '1';
                 fsm_address_load     <= '1';
                 fsm_prev_addr_load   <= '1';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '1';
                 fsm_o_en             <= '0';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when MEM_ADDR =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '0';
                 fsm_address_load     <= '1';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_mem_addr_sel     <= '1';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '1';
                 fsm_o_done           <= '0';
             when SAVE_TO_MEM =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '0';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '0';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '1';
                 fsm_first_addr_sel   <= '0';
                 fsm_first_addr_load  <= 'X';
                 fsm_delta_value_load <= '0';
                 fsm_mem_addr_sel     <= '0';
                 fsm_o_en             <= '1';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '0';
             when FINAL =>
                 fsm_col_load         <= '0';
                 fsm_row_load         <= '0';
                 fsm_row_sel          <= 'X';
                 fsm_new_prod_sel     <= '1';
                 fsm_prod_load        <= '0';
                 fsm_prod_load_sel    <= '1';
                 fsm_addr_sel_start   <= '1';
                 fsm_ctrl_addr        <= "XXXXXXXXXXXXXXXX";
                 fsm_ctrl_addr_sel    <= '0';
                 fsm_address_load     <= '0';
                 fsm_prev_addr_load   <= '0';
                 fsm_first_addr_sel   <= '1';
                 fsm_first_addr_load  <= '0';
                 fsm_delta_value_load <= '0';
                 fsm_o_en             <= '0';
                 fsm_o_we             <= '0';
                 fsm_o_done           <= '1';
             when ERROR =>
         end case;
     end process SIGNALS_PROCESS;
 end arch_finite_state_machine;

----------------------------------------------------------- PROJECT RETI LOGICHE ----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
  port (
    i_clk     : in std_logic;
    i_rst     : in std_logic;
    i_start   : in std_logic;
    i_data    : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done    : out std_logic;
    o_en      : out std_logic;
    o_we      : out std_logic;
    o_data    : out std_logic_vector (7 downto 0)
  );
end project_reti_logiche;


architecture arch_project_reti_logiche of project_reti_logiche is
 component processing_unit is port (
    -- In
    pu_i_rst            : in std_logic;
    pu_i_clk            : in std_logic;
    pu_i_data           : in std_logic_vector(7 downto 0);
    pu_col_load         : in std_logic;
    pu_row_load         : in std_logic;
    pu_row_sel          : in std_logic;
    pu_new_prod_sel     : in std_logic;
    pu_prod_load        : in std_logic;
    pu_prod_load_sel    : in std_logic;

    -- In
    pu_addr_sel_start   : in std_logic;
    pu_ctrl_addr        : in std_logic_vector(15 downto 0);
    pu_ctrl_addr_sel    : in std_logic;
    pu_address_load     : in std_logic;
    pu_prev_addr_load   : in std_logic;

    -- In
    pu_first_addr_sel   : in std_logic;
    pu_first_addr_load  : in std_logic;
    pu_delta_value_load : in std_logic;
    pu_mem_addr_sel     : in std_logic;

    -- To Memory
    pu_o_data    : out std_logic_vector(7 downto 0);
    pu_o_address : out std_logic_vector(15 downto 0);

    -- To controller
    pu_proc_over : out std_logic;
    pu_calc_over : out std_logic;
    pu_zero_col  : out std_logic;
    pu_zero_row  : out std_logic
  );
  end component;

  component finite_state_machine is port (
  -- output signals
    fsm_col_load      : out std_logic;
    fsm_row_load      : out std_logic;
    fsm_row_sel       : out std_logic;
    fsm_new_prod_sel  : out std_logic;
    fsm_prod_load     : out std_logic;
    fsm_prod_load_sel : out std_logic;

    fsm_addr_sel_start : out std_logic;
    fsm_ctrl_addr      : out std_logic_vector(15 downto 0);
    fsm_ctrl_addr_sel  : out std_logic;
    fsm_address_load   : out std_logic;
    fsm_prev_addr_load : out std_logic;

    fsm_first_addr_sel   : out std_logic;
    fsm_first_addr_load  : out std_logic;
    fsm_delta_value_load : out std_logic;
    fsm_mem_addr_sel     : out std_logic;

    fsm_o_en   : out std_logic;
    fsm_o_we   : out std_logic;
    fsm_o_done : out std_logic;

    -- input signals
    fsm_i_clk     : in std_logic;
    fsm_i_rst     : in std_logic;
    fsm_i_start   : in std_logic;
    fsm_proc_over : in std_logic;
    fsm_calc_over : in std_logic;
    fsm_zero_col  : in std_logic;
    fsm_zero_row  : in std_logic
  );
  end component;
  
  
  -- signals used by the project_reti_logiche module to connect the fsm and the processing unit 
  -- processing unit input signals
  signal col_load      : std_logic;
  signal row_load      : std_logic;
  signal row_sel       : std_logic;
  signal new_prod_sel  : std_logic;
  signal prod_load     : std_logic;
  signal prod_load_sel : std_logic;

  signal addr_sel_start : std_logic;
  signal ctrl_addr      : std_logic_vector(15 downto 0);
  signal ctrl_addr_sel  : std_logic;
  signal address_load   : std_logic;
  signal prev_addr_load : std_logic;

  signal first_addr_sel   : std_logic;
  signal first_addr_load  : std_logic;
  signal delta_value_load : std_logic;
  signal mem_addr_sel     : std_logic;


  -- processing unit output signals
  signal proc_over     : std_logic;
  signal calc_over     : std_logic;
  signal zero_col      : std_logic;
  signal zero_row      : std_logic;

begin
-- mapping internal signals with processing_unit output and input signals
  PU: processing_unit port map (
    pu_i_rst            => i_rst,
    pu_i_clk            => i_clk,
    pu_i_data           => i_data,
    pu_col_load         => col_load,
    pu_row_load         => row_load,
    pu_row_sel          => row_sel,
    pu_new_prod_sel     => new_prod_sel ,
    pu_prod_load        => prod_load,
    pu_prod_load_sel    => prod_load_sel,

    pu_addr_sel_start   => addr_sel_start,
    pu_ctrl_addr        => ctrl_addr,
    pu_ctrl_addr_sel    => ctrl_addr_sel,
    pu_address_load     => address_load,
    pu_prev_addr_load   => prev_addr_load,

    pu_first_addr_sel   => first_addr_sel,
    pu_first_addr_load  => first_addr_load,
    pu_delta_value_load => delta_value_load,
    pu_mem_addr_sel     => mem_addr_sel,

    -- To Memory
    pu_o_data    => o_data,
    pu_o_address => o_address,

    -- To controller
    pu_proc_over => proc_over,
    pu_calc_over => calc_over,
    pu_zero_col  => zero_col,
    pu_zero_row  => zero_row
  );
  
  -- mapping internal signals with finite_state_machine output and input signals
  FSM: finite_state_machine port map (
    fsm_col_load      => col_load,
    fsm_row_load      => row_load,
    fsm_row_sel       => row_sel,
    fsm_new_prod_sel  => new_prod_sel,
    fsm_prod_load     => prod_load,
    fsm_prod_load_sel => prod_load_sel,

    fsm_addr_sel_start => addr_sel_start,
    fsm_ctrl_addr      => ctrl_addr,
    fsm_ctrl_addr_sel  => ctrl_addr_sel,
    fsm_address_load   => address_load,
    fsm_prev_addr_load => prev_addr_load,

    fsm_first_addr_sel   => first_addr_sel,
    fsm_first_addr_load  => first_addr_load,
    fsm_delta_value_load => delta_value_load,
    fsm_mem_addr_sel     => mem_addr_sel,

    fsm_o_en   => o_en,
    fsm_o_we   => o_we,
    fsm_o_done => o_done,

    -- input signals
    fsm_i_clk     => i_clk,
    fsm_i_rst     => i_rst,
    fsm_i_start   => i_start,
    fsm_proc_over => proc_over,
    fsm_calc_over => calc_over,
    fsm_zero_col  => zero_col,
    fsm_zero_row  => zero_row
  );


end arch_project_reti_logiche;
