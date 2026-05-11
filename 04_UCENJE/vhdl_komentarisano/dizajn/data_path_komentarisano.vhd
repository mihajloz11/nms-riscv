-- ==================================================
-- ucenje verzija: data_path_komentarisano.vhd
-- uloga fajla: glavni put podataka kroz procesor
-- sustina: ovdje su PC, registri, immediate, ALU i memorijski put.
-- ako control_path "kaze sta", data_path to stvarno izvrsi.
-- ==================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity data_path is
   generic (DATA_WIDTH : positive := 32);
   port(
      -- ********* Globalna sinhronizacija ******************
      clk                 : in  std_logic;
      reset               : in  std_logic;
      -- ********* Interfejs ka Memoriji za instrukcije *****
      instr_mem_address_o : out std_logic_vector(31 downto 0);
      instr_mem_read_i    : in  std_logic_vector(31 downto 0);
      instruction_o       : out std_logic_vector(31 downto 0);
      -- ********* Interfejs ka Memoriji za podatke *****
      data_mem_address_o  : out std_logic_vector(31 downto 0);
      data_mem_write_o    : out std_logic_vector(31 downto 0);
      data_mem_read_i     : in  std_logic_vector(31 downto 0);
      -- ********* Kontrolni signali ************************
      mem_to_reg_i        : in  std_logic;
      alu_op_i            : in  std_logic_vector(4 downto 0);
      pc_next_sel_i       : in  std_logic;
      alu_src_i           : in  std_logic;
      rd_we_i             : in  std_logic;
      -- ********* Statusni signali *************************
      branch_condition_o  : out std_logic
    -- ******************************************************
      );

end entity;


architecture Behavioral of data_path is
   constant LOAD_OPCODE_C : std_logic_vector(6 downto 0) := "0000011";
   -- pc_reg_s je tekuci program counter
   signal pc_reg_s, pc_next_s                   : std_logic_vector (31 downto 0);
   -- glavni interni signali datapath-a
   signal instruction_s                         : std_logic_vector(31 downto 0);
   signal pc_adder_s                            : std_logic_vector(31 downto 0);
   signal branch_adder_s                        : std_logic_vector(31 downto 0);
   signal rs1_data_s, rs2_data_s, rd_data_s     : std_logic_vector (31 downto 0);
   signal immediate_extended_s, load_data_s     : std_logic_vector(31 downto 0);
   -- AlU signali   
   signal alu_zero_s, alu_of_o_s                : std_logic;
   signal b_s, a_s                              : std_logic_vector(31 downto 0);
   signal alu_result_s                          : std_logic_vector(31 downto 0);
--********************************************************
begin

   -- PC se mijenja samo na ivici takta
   pc_proc : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0')then
            pc_reg_s <= (others => '0');
         else
            pc_reg_s <= pc_next_s;
         end if;
      end if;
   end process;
   --*****************************************************

   -- sledeca sekvencijalna instrukcija je uvijek PC + 4
   pc_adder_s     <= std_logic_vector(unsigned(pc_reg_s) + to_unsigned(4, DATA_WIDTH));
   -- branch adresa je PC + immediate
   branch_adder_s <= std_logic_vector(unsigned(immediate_extended_s) + unsigned(pc_reg_s));

   -- Ovdje se stvarno provjerava branch uslov.
   process (instruction_s, a_s, b_s) is
   begin
      branch_condition_o <= '0';
      case instruction_s(14 downto 12) is
         when "000" =>
            if (a_s = b_s) then
               branch_condition_o <= '1';
            end if;
         when "001" =>
            if (a_s /= b_s) then
               branch_condition_o <= '1';
            end if;
         when "100" =>
            if (signed(a_s) < signed(b_s)) then
               branch_condition_o <= '1';
            end if;
         when "101" =>
            if (signed(a_s) >= signed(b_s)) then
               branch_condition_o <= '1';
            end if;
         when others =>
            null;
      end case;
   end process;

   -- PC MUX bira da li se ide na narednu instrukciju ili na branch metu
   with pc_next_sel_i select
      pc_next_s <= pc_adder_s when '0',
      branch_adder_s          when others;

   -- drugi operand ALU je ili rs2 ili immediate
   b_s <= rs2_data_s when alu_src_i = '0' else
          immediate_extended_s;
   -- prvi operand ALU je rs1
   a_s <= rs1_data_s;

   -- load_data_s dodatno obradi rezultat memorije za lb i lbu
   process (instruction_s, data_mem_read_i) is
   begin
      load_data_s <= data_mem_read_i;
      if (instruction_s(6 downto 0) = LOAD_OPCODE_C) then
         case instruction_s(14 downto 12) is
            when "000" =>
               load_data_s <= std_logic_vector(resize(signed(data_mem_read_i(7 downto 0)), DATA_WIDTH));
            when "100" =>
               load_data_s <= std_logic_vector(resize(unsigned(data_mem_read_i(7 downto 0)), DATA_WIDTH));
            when others =>
               load_data_s <= data_mem_read_i;
         end case;
      end if;
   end process;

   -- write-back MUX bira da li se u rd upisuje load ili ALU rezultat
   rd_data_s <= load_data_s when mem_to_reg_i = '1' else
                alu_result_s;
   --*****************************************************

   --***********Instanciranja*****************************

   --Registarska banka
   register_bank_1 : entity work.register_bank
      generic map (
         WIDTH => 32)
      port map (
         clk           => clk,
         reset         => reset,
         rd_we_i       => rd_we_i,
         rs1_address_i => instruction_s (19 downto 15),
         rs2_address_i => instruction_s (24 downto 20),
         rs1_data_o    => rs1_data_s,
         rs2_data_o    => rs2_data_s,
         rd_address_i  => instruction_s (11 downto 7),
         rd_data_i     => rd_data_s);


   -- Modul za prosirenje immediate polja instrukcije
   immediate_1 : entity work.immediate
      port map (
         instruction_i        => instruction_s,
         immediate_extended_o => immediate_extended_s
         );

   -- Aritmeticko logicka jedinica
   ALU_1 : entity work.ALU
      generic map (
         WIDTH => DATA_WIDTH)
      port map (
         a_i    => a_s,
         b_i    => b_s,
         op_i   => alu_op_i,
         res_o  => alu_result_s,
         zero_o => alu_zero_s,
         of_o   => alu_of_o_s);

   --*****************************************************

   --***********Ulazi/Izlazi******************************
   -- Ka controlpath-u
   instruction_o       <= instruction_s;
   -- Sa memorijom za instrukcije
   instruction_s       <= instr_mem_read_i;
   -- Sa memorijom za podatke
   instr_mem_address_o <= pc_reg_s;
   data_mem_address_o  <= alu_result_s;
   data_mem_write_o    <= rs2_data_s;
end architecture;
