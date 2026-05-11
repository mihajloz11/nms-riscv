library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;
use work.txt_util.all;

entity TOP_testovi is
   generic (
      SCENARIO_ID_G : integer := 1;
      PROGRAM_PATH_G : string := "rv32i/testovi/assembly_code_active.txt"
      );
end entity;

architecture behavioral of TOP_testovi is
   constant SCENARIO_rv32i_C : integer := 0;
   constant SCENARIO_ZBB_C : integer := 1;
   constant SCENARIO_EXTENDED_C : integer := 2;

   type word_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
   type addr_array_t is array (natural range <>) of natural;

   -- ulazi i ocekivani store rezultati za rv32i regresiju
   constant rv32i_INPUT_ADDRS_C : addr_array_t(0 to 1) := (0, 4);
   constant rv32i_INPUT_DATA_C : word_array_t(0 to 1) := (x"00000005", x"00000007");
   constant rv32i_EXPECT_ADDRS_C : addr_array_t(0 to 5) := (32, 36, 40, 44, 48, 52);
   constant rv32i_EXPECT_DATA_C : word_array_t(0 to 5) := (
      x"0000000C",
      x"00000002",
      x"00000005",
      x"00000007",
      x"00000008",
      x"0000004D");

   -- ulazi i ocekivani store rezultati za zbb demo
   constant ZBB_INPUT_ADDRS_C : addr_array_t(0 to 4) := (0, 4, 8, 12, 16);
   constant ZBB_INPUT_DATA_C : word_array_t(0 to 4) := (
      x"00FF00FF",
      x"FFFF0000",
      x"0000F000",
      x"00000010",
      x"F0F0F0F0");
   constant ZBB_EXPECT_ADDRS_C : addr_array_t(0 to 9) := (32, 36, 40, 44, 48, 52, 56, 60, 64, 68);
   constant ZBB_EXPECT_DATA_C : word_array_t(0 to 9) := (
      x"FF000000",
      x"00000010",
      x"00000010",
      x"00000004",
      x"FFFFFF00",
      x"00FFFF00",
      x"0FF00FF0",
      x"F00FF00F",
      x"FFFFFFFF",
      x"FFFFF000");

   -- ulazi i ocekivani store rezultati za prosireni cpu demo
   constant EXT_INPUT_ADDRS_C : addr_array_t(0 to 5) := (0, 4, 8, 12, 16, 20);
   constant EXT_INPUT_DATA_C : word_array_t(0 to 5) := (
      x"00FF00FF",
      x"FFFF0000",
      x"0000F000",
      x"00000010",
      x"F0F0F0F0",
      x"1234FF80");
   constant EXT_EXPECT_ADDRS_C : addr_array_t(0 to 45) := (
      80, 84, 88, 92, 96, 100, 104, 108, 24, 112, 116, 120, 124,
      128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172,
      176, 28, 180, 184, 188, 192, 196,
      200, 204, 208, 212, 216, 220, 224, 228, 232, 236, 240, 244, 248, 256);
   constant EXT_EXPECT_DATA_C : word_array_t(0 to 45) := (
      x"FF0000FF",
      x"0000001F",
      x"00000080",
      x"00000001",
      x"00000002",
      x"00000003",
      x"FFFFFF80",
      x"00000080",
      x"00000010",
      x"00000010",
      x"00000004",
      x"00000005",
      x"00000006",
      x"12345000",
      x"000000A0",
      x"00000001",
      x"00000000",
      x"00000001",
      x"00000000",
      x"0FFFFFFF",
      x"FFFFFFFF",
      x"7FFFFFFF",
      x"FFFFFFFF",
      x"000000A0",
      x"FFFFFF80",
      x"0000FF80",
      x"0000FF80",
      x"0000FF80",
      x"00000005",
      x"00000007",
      x"0000013C",
      x"0000014C",
      x"FFFFFFBF",
      x"FFFFFFFF",
      x"00000004",
      x"FFFFFFFF",
      x"FFFFFFFE",
      x"33333330",
      x"FFFFFFFD",
      x"00000003",
      x"FFFFFFFF",
      x"FFFFFFF3",
      x"80000000",
      x"00000000",
      x"00000003",
      x"000001E4");

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ena_instr_s : std_logic := '1';
   signal enb_instr_s : std_logic;
   signal wea_instr_s : std_logic_vector(3 downto 0) := (others => '0');
   signal web_instr_s : std_logic_vector(3 downto 0) := (others => '0');
   signal addra_instr_s : std_logic_vector(9 downto 0) := (others => '0');
   signal addrb_instr_s : std_logic_vector(9 downto 0);
   signal dina_instr_s : std_logic_vector(31 downto 0) := (others => '0');
   signal dinb_instr_s : std_logic_vector(31 downto 0) := (others => '0');
   signal douta_instr_s, doutb_instr_s : std_logic_vector(31 downto 0);
   signal addrb_instr_32_s : std_logic_vector(31 downto 0) := (others => '0');
   signal ena_data_s : std_logic;
   signal enb_data_s : std_logic := '1';
   signal wea_data_s : std_logic_vector(3 downto 0) := (others => '0');
   signal web_data_s : std_logic_vector(3 downto 0) := (others => '0');
   signal addra_data_s : std_logic_vector(9 downto 0);
   signal addrb_data_s : std_logic_vector(9 downto 0) := (others => '0');
   signal dina_data_s : std_logic_vector(31 downto 0) := (others => '0');
   signal dinb_data_s : std_logic_vector(31 downto 0) := (others => '0');
   signal douta_data_s, doutb_data_s : std_logic_vector(31 downto 0);
   signal addra_data_32_s : std_logic_vector(31 downto 0) := (others => '0');
   signal instr_mem_cpu_s : std_logic_vector(31 downto 0);
   signal data_mem_cpu_s : std_logic_vector(31 downto 0);

   function slv32(value : natural) return std_logic_vector is
   begin
      return std_logic_vector(to_unsigned(value, 32));
   end function;

   function hex_char(value : natural) return character is
      constant HEX_C : string := "0123456789ABCDEF";
   begin
      return HEX_C(value + 1);
   end function;

   function slv_to_hex(value : std_logic_vector) return string is
      constant NIBBLE_COUNT_C : natural := value'length / 4;
      variable result_v : string(1 to NIBBLE_COUNT_C);
      variable nibble_v : unsigned(3 downto 0);
      variable hi_v : integer;
      variable lo_v : integer;
   begin
      for i in 0 to NIBBLE_COUNT_C - 1 loop
         hi_v := value'length - 1 - (i * 4);
         lo_v := hi_v - 3;
         nibble_v := unsigned(value(hi_v downto lo_v));
         result_v(i + 1) := hex_char(to_integer(nibble_v));
      end loop;
      return result_v;
   end function;

   procedure open_program_file(file instructions_f : text) is
      variable status_v : file_open_status;
   begin
      file_open(status_v, instructions_f, PROGRAM_PATH_G, read_mode);
      if (status_v = open_ok) then
         return;
      end if;

      file_open(status_v, instructions_f, "rv32i/testovi/assembly_code_active.txt", read_mode);
      if (status_v = open_ok) then
         return;
      end if;

      file_open(status_v, instructions_f, "../../../../../testovi/assembly_code_active.txt", read_mode);
      if (status_v = open_ok) then
         return;
      end if;

      assert false
         report "Unable to open instruction program file"
         severity failure;
   end procedure;

begin

   enb_instr_s <= reset;
   addrb_instr_s <= addrb_instr_32_s(9 downto 0);
   instr_mem_cpu_s <= doutb_instr_s when reset = '1' else (others => '0');

   addra_data_s <= addra_data_32_s(9 downto 0);
   ena_data_s <= reset;
   data_mem_cpu_s <= douta_data_s when reset = '1' else (others => '0');

   instruction_mem : entity work.BRAM(behavioral)
      generic map (WADDR => 10)
      port map (
         clk => clk,
         en_a_i => ena_instr_s,
         we_a_i => wea_instr_s,
         addr_a_i => addra_instr_s,
         data_a_i => dina_instr_s,
         data_a_o => douta_instr_s,
         en_b_i => enb_instr_s,
         we_b_i => web_instr_s,
         addr_b_i => addrb_instr_s,
         data_b_i => dinb_instr_s,
         data_b_o => doutb_instr_s);

   data_mem : entity work.BRAM(behavioral)
      generic map (WADDR => 10)
      port map (
         clk => clk,
         en_a_i => ena_data_s,
         we_a_i => wea_data_s,
         addr_a_i => addra_data_s,
         data_a_i => dina_data_s,
         data_a_o => douta_data_s,
         en_b_i => enb_data_s,
         we_b_i => web_data_s,
         addr_b_i => addrb_data_s,
         data_b_i => dinb_data_s,
         data_b_o => doutb_data_s);

   TOP_RISCV_1 : entity work.TOP_RISCV
      port map (
         clk => clk,
         reset => reset,
         instr_mem_read_i => instr_mem_cpu_s,
         instr_mem_address_o => addrb_instr_32_s,
         data_mem_we_o => wea_data_s,
         data_mem_address_o => addra_data_32_s,
         data_mem_read_i => data_mem_cpu_s,
         data_mem_write_o => dina_data_s);

   init_proc : process
      file RISCV_instructions_v : text;
      variable instruction_bits_v : string(1 to 32);
      variable instruction_addr_v : natural := 0;
   begin
      -- ucitava program u instruction memoriju i puni data memoriju test podacima
      open_program_file(RISCV_instructions_v);
      wait until rising_edge(clk);

      wea_instr_s <= (others => '1');
      while (not endfile(RISCV_instructions_v)) loop
         str_read(RISCV_instructions_v, instruction_bits_v);
         if (instruction_bits_v(1) = '0' or instruction_bits_v(1) = '1') then
            addra_instr_s <= std_logic_vector(to_unsigned(instruction_addr_v, addra_instr_s'length));
            dina_instr_s <= to_std_logic_vector(instruction_bits_v);
            instruction_addr_v := instruction_addr_v + 4;
         end if;
         wait until rising_edge(clk);
      end loop;
      file_close(RISCV_instructions_v);
      wea_instr_s <= (others => '0');

      case SCENARIO_ID_G is
         when SCENARIO_rv32i_C =>
            for i in rv32i_INPUT_ADDRS_C'range loop
               addrb_data_s <= std_logic_vector(to_unsigned(rv32i_INPUT_ADDRS_C(i), addrb_data_s'length));
               dinb_data_s <= rv32i_INPUT_DATA_C(i);
               web_data_s <= (others => '1');
               wait until rising_edge(clk);
            end loop;
         when SCENARIO_EXTENDED_C =>
            for i in EXT_INPUT_ADDRS_C'range loop
               addrb_data_s <= std_logic_vector(to_unsigned(EXT_INPUT_ADDRS_C(i), addrb_data_s'length));
               dinb_data_s <= EXT_INPUT_DATA_C(i);
               web_data_s <= (others => '1');
               wait until rising_edge(clk);
            end loop;
         when others =>
            for i in ZBB_INPUT_ADDRS_C'range loop
               addrb_data_s <= std_logic_vector(to_unsigned(ZBB_INPUT_ADDRS_C(i), addrb_data_s'length));
               dinb_data_s <= ZBB_INPUT_DATA_C(i);
               web_data_s <= (others => '1');
               wait until rising_edge(clk);
            end loop;
      end case;

      web_data_s <= (others => '0');
      addrb_data_s <= (others => '0');
      dinb_data_s <= (others => '0');

      wait until rising_edge(clk);
      reset <= '1';
      wait;
   end process;

   monitor_proc : process
      variable store_index_v : natural := 0;
   begin
      -- provjerava redosled i vrednosti store operacija koje cpu pravi
      wait until reset = '1';
      loop
         wait until rising_edge(clk);
         if (wea_data_s /= "0000") then
            report "CPU store observed: addr=0x" & slv_to_hex(addra_data_32_s) &
               " data=0x" & slv_to_hex(dina_data_s)
               severity note;
            case SCENARIO_ID_G is
               when SCENARIO_rv32i_C =>
                  assert store_index_v <= rv32i_EXPECT_ADDRS_C'high
                     report "Unexpected extra store in rv32i regression scenario"
                     severity failure;
                  assert addra_data_32_s = slv32(rv32i_EXPECT_ADDRS_C(store_index_v))
                     report "Unexpected rv32i store address at index " & integer'image(store_index_v)
                     severity failure;
                  assert dina_data_s = rv32i_EXPECT_DATA_C(store_index_v)
                     report "Unexpected rv32i store data at index " & integer'image(store_index_v)
                     severity failure;
                  store_index_v := store_index_v + 1;
                  if (store_index_v = rv32i_EXPECT_ADDRS_C'length) then
                     report "rv32i regression CPU test passed" severity note;
                     finish;
                  end if;
               when SCENARIO_EXTENDED_C =>
                  assert store_index_v <= EXT_EXPECT_ADDRS_C'high
                     report "Unexpected extra store in extended CPU scenario"
                     severity failure;
                  assert addra_data_32_s = slv32(EXT_EXPECT_ADDRS_C(store_index_v))
                     report "Unexpected extended store address at index " & integer'image(store_index_v)
                     severity failure;
                  assert dina_data_s = EXT_EXPECT_DATA_C(store_index_v)
                     report "Unexpected extended store data at index " & integer'image(store_index_v)
                     severity failure;
                  store_index_v := store_index_v + 1;
                  if (store_index_v = EXT_EXPECT_ADDRS_C'length) then
                     report "Extended CPU demo test passed" severity note;
                     finish;
                  end if;
               when others =>
                  assert store_index_v <= ZBB_EXPECT_ADDRS_C'high
                     report "Unexpected extra store in Zbb demo scenario"
                     severity failure;
                  assert addra_data_32_s = slv32(ZBB_EXPECT_ADDRS_C(store_index_v))
                     report "Unexpected Zbb store address at index " & integer'image(store_index_v)
                     severity failure;
                  assert dina_data_s = ZBB_EXPECT_DATA_C(store_index_v)
                     report "Unexpected Zbb store data at index " & integer'image(store_index_v)
                     severity failure;
                  store_index_v := store_index_v + 1;
                  if (store_index_v = ZBB_EXPECT_ADDRS_C'length) then
                     report "Zbb CPU demo test passed" severity note;
                     finish;
                  end if;
            end case;
         end if;
      end loop;
   end process;

   timeout_proc : process
   begin
      wait until reset = '1';
      wait for 60 us;
      assert false report "CPU-level test timed out" severity failure;
   end process;

   clk_proc : process
   begin
      clk <= '1', '0' after 100 ns;
      wait for 200 ns;
   end process;

end architecture;
