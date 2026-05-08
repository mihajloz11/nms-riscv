library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity podaci is
   generic (DATA_WIDTH : positive := 32);
   port (
      -- globalna sinhronizacija
      clk : in std_logic;
      reset : in std_logic;
      -- interfejs ka memoriji za instrukcije
      instr_mem_address_o : out std_logic_vector(31 downto 0);
      instr_mem_read_i : in std_logic_vector(31 downto 0);
      instruction_o : out std_logic_vector(31 downto 0);
      -- interfejs ka memoriji za podatke
      data_mem_address_o : out std_logic_vector(31 downto 0);
      data_mem_write_o : out std_logic_vector(31 downto 0);
      data_mem_read_i : in std_logic_vector(31 downto 0);
      -- kontrolni signali
      mem_to_reg_i : in std_logic;
      alu_op_i : in std_logic_vector(4 downto 0);
      pc_next_sel_i : in std_logic_vector(1 downto 0);
      alu_src_i : in std_logic;
      alu_src_a_i : in std_logic_vector(1 downto 0);
      rd_src_i : in std_logic_vector(1 downto 0);
      rd_we_i : in std_logic;
      -- statusni signali
      branch_condition_o : out std_logic

      );

end entity;

architecture behavioral of podaci is
   constant LOAD_OPCODE_C : std_logic_vector(6 downto 0) := "0000011";
   -- registri
   signal pc_reg_s, pc_next_s : std_logic_vector(31 downto 0);

   -- signali
   signal instruction_s : std_logic_vector(31 downto 0);
   signal pc_adder_s : std_logic_vector(31 downto 0);
   signal branch_adder_s : std_logic_vector(31 downto 0);
   signal jalr_adder_s, jalr_next_s : std_logic_vector(31 downto 0);
   signal rs1_data_s, rs2_data_s, rd_data_s : std_logic_vector(31 downto 0);
   signal immediate_extended_s, load_data_s : std_logic_vector(31 downto 0);
   -- alu signali
   signal alu_zero_s, alu_of_o_s : std_logic;
   signal b_s, a_s : std_logic_vector(31 downto 0);
   signal alu_result_s : std_logic_vector(31 downto 0);

begin

   -- sekvencijalna logika
   pc_proc : process (clk) is
   begin
      if (rising_edge(clk)) then
         if (reset = '0') then
            pc_reg_s <= (others => '0');
         else
            pc_reg_s <= pc_next_s;
         end if;
      end if;
   end process;

   -- kombinaciona logika
   -- sabirac za uvecavanje programskog brojaca (sledeca instrukcija)
   pc_adder_s <= std_logic_vector(unsigned(pc_reg_s) + to_unsigned(4, DATA_WIDTH));
   -- sabirac za uslovne skokove
   branch_adder_s <= std_logic_vector(unsigned(immediate_extended_s) + unsigned(pc_reg_s));
   -- jalr skok se racuna kao rs1 + immediate, a najnizi bit se postavlja na 0
   jalr_adder_s <= std_logic_vector(unsigned(rs1_data_s) + unsigned(immediate_extended_s));
   jalr_next_s <= jalr_adder_s(31 downto 1) & '0';

   -- za grananja gledamo funct3 polje i onda proveravamo odgovarajuci uslov.
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
         when "110" =>
            if (unsigned(a_s) < unsigned(b_s)) then
               branch_condition_o <= '1';
            end if;
         when "111" =>
            if (unsigned(a_s) >= unsigned(b_s)) then
               branch_condition_o <= '1';
            end if;
         when others =>
            null;
      end case;
   end process;

   -- mux koji odredjuje sledecu vrednost za programski brojac.
   -- ako se ne desi skok programski brojac se uvecava za 4.
   with pc_next_sel_i select
      pc_next_s <= pc_adder_s when "00",
                   branch_adder_s when "01",
                   jalr_next_s when "10",
                   pc_adder_s when others;

   -- mux koji odredjuje prvi operand alu jedinice.
   process (alu_src_a_i, rs1_data_s, pc_reg_s) is
   begin
      case alu_src_a_i is
         when "00" =>
            a_s <= rs1_data_s;
         when "01" =>
            a_s <= pc_reg_s;
         when others =>
            a_s <= (others => '0');
      end case;
   end process;

   -- mux koji odredjuje sledecu vrednost za b ulaz alu jedinice.
   b_s <= rs2_data_s when alu_src_i = '0' else
          immediate_extended_s;

   -- za load instrukcije uzima se onoliko bita koliko instrukcija trazi.
   process (instruction_s, data_mem_read_i) is
   begin
      load_data_s <= data_mem_read_i;
      if (instruction_s(6 downto 0) = LOAD_OPCODE_C) then
         case instruction_s(14 downto 12) is
            when "000" =>
               load_data_s <= std_logic_vector(resize(signed(data_mem_read_i(7 downto 0)), DATA_WIDTH));
            when "001" =>
               load_data_s <= std_logic_vector(resize(signed(data_mem_read_i(15 downto 0)), DATA_WIDTH));
            when "100" =>
               load_data_s <= std_logic_vector(resize(unsigned(data_mem_read_i(7 downto 0)), DATA_WIDTH));
            when "101" =>
               load_data_s <= std_logic_vector(resize(unsigned(data_mem_read_i(15 downto 0)), DATA_WIDTH));
            when others =>
               load_data_s <= data_mem_read_i;
         end case;
      end if;
   end process;

   -- mux koji odredjuje sta se upisuje u odredisni registar(rd_data_s)
   process (rd_src_i, load_data_s, alu_result_s, pc_adder_s) is
   begin
      case rd_src_i is
         when "01" =>
            rd_data_s <= load_data_s;
         when "10" =>
            rd_data_s <= pc_adder_s;
         when others =>
            rd_data_s <= alu_result_s;
      end case;
   end process;

   -- instanciranja

   -- registarska banka
   register_bank_1 : entity work.register_bank
      generic map (
         WIDTH => 32)
      port map (
         clk => clk,
         reset => reset,
         rd_we_i => rd_we_i,
         rs1_address_i => instruction_s (19 downto 15),
         rs2_address_i => instruction_s (24 downto 20),
         rs1_data_o => rs1_data_s,
         rs2_data_o => rs2_data_s,
         rd_address_i => instruction_s (11 downto 7),
         rd_data_i => rd_data_s);

   -- modul za prosirenje immediate polja instrukcije
   immediate_1 : entity work.immediate
      port map (
         instruction_i => instruction_s,
         immediate_extended_o => immediate_extended_s
         );

   -- aritmeticko logicka jedinica
   ALU_1 : entity work.ALU
      generic map (
         WIDTH => DATA_WIDTH)
      port map (
         a_i => a_s,
         b_i => b_s,
         op_i => alu_op_i,
         res_o => alu_result_s,
         zero_o => alu_zero_s,
         of_o => alu_of_o_s);

   -- ulazi/izlazi
   -- ka kontroli
   instruction_o <= instruction_s;
   -- sa memorijom za instrukcije
   instruction_s <= instr_mem_read_i;
   -- sa memorijom za podatke
   instr_mem_address_o <= pc_reg_s;
   data_mem_address_o <= alu_result_s;
   data_mem_write_o <= rs2_data_s;
end architecture;
