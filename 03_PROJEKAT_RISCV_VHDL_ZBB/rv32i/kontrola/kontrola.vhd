library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kontrola is
   port (clk : in std_logic;
         reset : in std_logic;
         -- instrukcija iz putanje podataka
         instruction_i : in std_logic_vector(31 downto 0);
         -- kontrolni signali
         mem_to_reg_o : out std_logic;
         alu_op_o : out std_logic_vector(4 downto 0);
         pc_next_sel_o : out std_logic_vector(1 downto 0);
         alu_src_o : out std_logic;
         alu_src_a_o : out std_logic_vector(1 downto 0);
         rd_src_o : out std_logic_vector(1 downto 0);
         rd_we_o : out std_logic;
         -- ulazni statusni interfejs
         branch_condition_i : in std_logic;
         -- izlazni statusni interfejs
         data_mem_we_o : out std_logic_vector(3 downto 0)
         );
end entity;

architecture behavioral of kontrola is
   signal alu_2bit_op_s : std_logic_vector(1 downto 0);
   signal data_mem_we_s : std_logic;
   signal branch_s : std_logic;
   signal jump_s : std_logic;
   signal jalr_s : std_logic;
begin

   process (branch_condition_i, branch_s, jump_s, jalr_s) is
   begin
      pc_next_sel_o <= "00";
      if (jalr_s = '1') then
         pc_next_sel_o <= "10";
      elsif (jump_s = '1') then
         pc_next_sel_o <= "01";
      elsif (branch_s = '1' and branch_condition_i = '1') then
         pc_next_sel_o <= "01";
      end if;
   end process;

   ctrl_dec : entity work.ctrl_decoder(behavioral)
      port map (
         opcode_i => instruction_i(6 downto 0),
         branch_o => branch_s,
         mem_to_reg_o => mem_to_reg_o,
         data_mem_we_o => data_mem_we_s,
         alu_src_o => alu_src_o,
         alu_src_a_o => alu_src_a_o,
         rd_src_o => rd_src_o,
         rd_we_o => rd_we_o,
         alu_2bit_op_o => alu_2bit_op_s,
         jump_o => jump_s,
         jalr_o => jalr_s);

   alu_dec : entity work.alu_decoder(behavioral)
      port map (
         alu_2bit_op_i => alu_2bit_op_s,
         funct3_i => instruction_i(14 downto 12),
         funct7_i => instruction_i(31 downto 25),
         funct12_i => instruction_i(31 downto 20),
         alu_op_o => alu_op_o);

   -- za sb se upisuje 1 bajt, za sh 2 bajta, a za sw sva 4 bajta
   process (data_mem_we_s, instruction_i) is
   begin
      data_mem_we_o <= (others => '0');
      if (data_mem_we_s = '1') then
         case instruction_i(14 downto 12) is
            when "000" =>
               data_mem_we_o <= "0001";
            when "001" =>
               data_mem_we_o <= "0011";
            when "010" =>
               data_mem_we_o <= "1111";
            when others =>
               data_mem_we_o <= (others => '0');
         end case;
      end if;
   end process;

end architecture;
