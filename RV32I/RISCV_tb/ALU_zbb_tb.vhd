library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use work.alu_ops_pkg.all;

entity ALU_zbb_tb is
end entity;

architecture behavioral of ALU_zbb_tb is
   signal a_s    : std_logic_vector(31 downto 0) := (others => '0');
   signal b_s    : std_logic_vector(31 downto 0) := (others => '0');
   signal op_s   : std_logic_vector(4 downto 0) := add_op;
   signal res_s  : std_logic_vector(31 downto 0);
   signal zero_s : std_logic;
   signal of_s   : std_logic;
begin

   dut : entity work.ALU
      generic map (WIDTH => 32)
      port map (
         a_i    => a_s,
         b_i    => b_s,
         op_i   => op_s,
         res_o  => res_s,
         zero_o => zero_s,
         of_o   => of_s);

   stim_proc : process
      procedure check_case (
         constant case_name : in string;
         constant a_value   : in std_logic_vector(31 downto 0);
         constant b_value   : in std_logic_vector(31 downto 0);
         constant op_value  : in std_logic_vector(4 downto 0);
         constant expected  : in std_logic_vector(31 downto 0)) is
      begin
         a_s  <= a_value;
         b_s  <= b_value;
         op_s <= op_value;
         wait for 1 ns;
         assert res_s = expected
            report case_name & " failed"
            severity failure;
      end procedure;
   begin
      check_case("andn_mixed_mask", x"FFFF0000", x"00FF00FF", andn_op, x"FF000000");
      check_case("orn_mixed_mask", x"FFFF0000", x"00FF00FF", orn_op, x"FFFFFF00");
      check_case("xor_mixed_mask", x"00FF00FF", x"FFFF0000", xor_op, x"FF0000FF");
      check_case("xnor_mixed_mask", x"FFFF0000", x"00FF00FF", xnor_op, x"00FFFF00");
      check_case("sll_by_three", x"00000010", x"00000003", sll_op, x"00000080");
      check_case("srl_by_four", x"80000000", x"00000004", srl_op, x"08000000");
      check_case("sra_negative_by_two", x"FFFFFFF0", x"00000002", sra_op, x"FFFFFFFC");
      check_case("slt_signed_true", x"FFFFFFFF", x"00000001", lts_op, x"00000001");
      check_case("sltu_unsigned_false", x"FFFFFFFF", x"00000001", ltu_op, x"00000000");
      check_case("sltu_unsigned_true", x"00000001", x"FFFFFFFF", ltu_op, x"00000001");
      check_case("mul_negative", x"FFFFFFF3", x"00000005", mulu_op, x"FFFFFFBF");
      check_case("mulh_negative", x"FFFFFFF3", x"00000005", mulhs_op, x"FFFFFFFF");
      check_case("mulhsu_negative", x"FFFFFFF3", x"00000005", mulhsu_op, x"FFFFFFFF");
      check_case("mulhu_large", x"FFFFFFF3", x"00000005", mulhu_op, x"00000004");
      check_case("div_signed", x"FFFFFFF3", x"00000005", divs_op, x"FFFFFFFE");
      check_case("div_unsigned", x"FFFFFFF3", x"00000005", divu_op, x"33333330");
      check_case("rem_signed", x"FFFFFFF3", x"00000005", rems_op, x"FFFFFFFD");
      check_case("rem_unsigned", x"FFFFFFF3", x"00000005", remu_op, x"00000003");
      check_case("div_by_zero", x"FFFFFFF3", x"00000000", divs_op, x"FFFFFFFF");
      check_case("rem_by_zero", x"FFFFFFF3", x"00000000", rems_op, x"FFFFFFF3");
      check_case("div_overflow", x"80000000", x"FFFFFFFF", divs_op, x"80000000");
      check_case("rem_overflow", x"80000000", x"FFFFFFFF", rems_op, x"00000000");

      check_case("clz_zero", x"00000000", x"00000000", clz_op, x"00000020");
      check_case("clz_msb_set", x"80000000", x"00000000", clz_op, x"00000000");
      check_case("clz_mid_word", x"0000F000", x"00000000", clz_op, x"00000010");

      check_case("ctz_zero", x"00000000", x"00000000", ctz_op, x"00000020");
      check_case("ctz_one", x"00000001", x"00000000", ctz_op, x"00000000");
      check_case("ctz_single_bit", x"00000010", x"00000000", ctz_op, x"00000004");

      check_case("cpop_zero", x"00000000", x"00000000", cpop_op, x"00000000");
      check_case("cpop_all_ones", x"FFFFFFFF", x"00000000", cpop_op, x"00000020");
      check_case("cpop_pattern", x"F0F0F0F0", x"00000000", cpop_op, x"00000010");
      check_case("rol_by_four", x"12345678", x"00000004", rol_op, x"23456781");
      check_case("ror_by_four", x"12345678", x"00000004", ror_op, x"81234567");
      check_case("signextb_negative", x"000000FF", x"00000000", signextb_op, x"FFFFFFFF");
      check_case("signexth_negative", x"0000F000", x"00000000", signexth_op, x"FFFFF000");

      report "ALU extended tests passed" severity note;
      finish;
   end process;

end architecture;
