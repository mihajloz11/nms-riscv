LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.alu_ops_pkg.all;


ENTITY ALU IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
      op_i   : in STD_LOGIC_VECTOR(4 DOWNTO 0); --port za izbor operacije
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --rezultat
      zero_o : out STD_LOGIC; -- signal da je rezultat nula
      of_o   : out STD_LOGIC); -- signal da je doslo do prekoracenja opsega
END ALU;

ARCHITECTURE behavioral OF ALU IS
   function count_leading_zeros(vec : std_logic_vector) return std_logic_vector is
      variable count_v : natural := 0;
   begin
      for i in vec'range loop
         if vec(i) = '0' then
            count_v := count_v + 1;
         else
            return std_logic_vector(to_unsigned(count_v, vec'length));
         end if;
      end loop;
      return std_logic_vector(to_unsigned(vec'length, vec'length));
   end function;

   function count_trailing_zeros(vec : std_logic_vector) return std_logic_vector is
      variable count_v : natural := 0;
   begin
      for i in 0 to vec'length - 1 loop
         if vec(i) = '0' then
            count_v := count_v + 1;
         else
            return std_logic_vector(to_unsigned(count_v, vec'length));
         end if;
      end loop;
      return std_logic_vector(to_unsigned(vec'length, vec'length));
   end function;

   function count_population(vec : std_logic_vector) return std_logic_vector is
      variable count_v : natural := 0;
   begin
      for i in vec'range loop
         if vec(i) = '1' then
            count_v := count_v + 1;
         end if;
      end loop;
      return std_logic_vector(to_unsigned(count_v, vec'length));
   end function;

   function sign_extend_byte(vec : std_logic_vector) return std_logic_vector is
      variable result_v : std_logic_vector(vec'range);
      variable sign_v   : std_logic := '0';
   begin
      result_v := (others => '0');
      sign_v := vec(7);
      result_v(7 downto 0) := vec(7 downto 0);
      for i in 8 to vec'length - 1 loop
         result_v(i) := sign_v;
      end loop;
      return result_v;
   end function;

   function sign_extend_halfword(vec : std_logic_vector) return std_logic_vector is
      variable result_v : std_logic_vector(vec'range);
      variable sign_v   : std_logic := '0';
   begin
      result_v := (others => '0');
      sign_v := vec(15);
      result_v(15 downto 0) := vec(15 downto 0);
      for i in 16 to vec'length - 1 loop
         result_v(i) := sign_v;
      end loop;
      return result_v;
   end function;

   function rotate_left_simple(vec : std_logic_vector; shamt : natural) return std_logic_vector is
      variable shift_v : natural := 0;
   begin
      if vec'length = 0 then
         return vec;
      end if;

      shift_v := shamt mod vec'length;
      if shift_v = 0 then
         return vec;
      end if;

      return std_logic_vector(shift_left(unsigned(vec), shift_v) or shift_right(unsigned(vec), vec'length - shift_v));
   end function;

   function get_shift_amount(vec : std_logic_vector) return natural is
      variable amount_v : natural := 0;
   begin
      for i in vec'range loop
         if vec(i) = '1' then
            amount_v := amount_v + (2 ** i);
         end if;
      end loop;
      return amount_v;
   end function;

   function rotate_right_simple(vec : std_logic_vector; shamt : natural) return std_logic_vector is
      variable shift_v : natural := 0;
   begin
      if vec'length = 0 then
         return vec;
      end if;

      shift_v := shamt mod vec'length;
      if shift_v = 0 then
         return vec;
      end if;

      return std_logic_vector(shift_right(unsigned(vec), shift_v) or shift_left(unsigned(vec), vec'length - shift_v));
   end function;

   function multiply_lower(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable product_v : signed((2 * a_vec'length) - 1 downto 0);
   begin
      product_v := signed(a_vec) * signed(b_vec);
      return std_logic_vector(product_v(a_vec'length - 1 downto 0));
   end function;

   function multiply_high_signed(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable product_v : signed((2 * a_vec'length) - 1 downto 0);
   begin
      product_v := signed(a_vec) * signed(b_vec);
      return std_logic_vector(product_v((2 * a_vec'length) - 1 downto a_vec'length));
   end function;

   function multiply_high_signed_unsigned(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable product_v : signed((4 * a_vec'length) - 1 downto 0);
   begin
      product_v := resize(signed(a_vec), 2 * a_vec'length) * signed(resize(unsigned(b_vec), 2 * b_vec'length));
      return std_logic_vector(product_v((2 * a_vec'length) - 1 downto a_vec'length));
   end function;

   function multiply_high_unsigned(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable product_v : unsigned((2 * a_vec'length) - 1 downto 0);
   begin
      product_v := unsigned(a_vec) * unsigned(b_vec);
      return std_logic_vector(product_v((2 * a_vec'length) - 1 downto a_vec'length));
   end function;

   function is_most_negative(a_vec : std_logic_vector) return boolean is
      variable min_v : std_logic_vector(a_vec'range);
   begin
      min_v := (others => '0');
      min_v(a_vec'left) := '1';
      return a_vec = min_v;
   end function;

   function is_minus_one(a_vec : std_logic_vector) return boolean is
      variable minus_one_v : std_logic_vector(a_vec'range);
   begin
      minus_one_v := (others => '1');
      return a_vec = minus_one_v;
   end function;

   function divide_signed_simple(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable result_v : std_logic_vector(a_vec'range);
   begin
      if unsigned(b_vec) = 0 then
         result_v := (others => '1');
         return result_v;
      elsif is_most_negative(a_vec) and is_minus_one(b_vec) then
         return a_vec;
      else
         return std_logic_vector(signed(a_vec) / signed(b_vec));
      end if;
   end function;

   function divide_unsigned_simple(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable result_v : std_logic_vector(a_vec'range);
   begin
      if unsigned(b_vec) = 0 then
         result_v := (others => '1');
         return result_v;
      else
         return std_logic_vector(unsigned(a_vec) / unsigned(b_vec));
      end if;
   end function;

   function reminder_signed_simple(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
      variable result_v : std_logic_vector(a_vec'range);
   begin
      if unsigned(b_vec) = 0 then
         return a_vec;
      elsif is_most_negative(a_vec) and is_minus_one(b_vec) then
         result_v := (others => '0');
         return result_v;
      else
         return std_logic_vector(signed(a_vec) rem signed(b_vec));
      end if;
   end function;

   function reminder_unsigned_simple(a_vec : std_logic_vector; b_vec : std_logic_vector) return std_logic_vector is
   begin
      if unsigned(b_vec) = 0 then
         return a_vec;
      else
         return std_logic_vector(unsigned(a_vec) rem unsigned(b_vec));
      end if;
   end function;

   signal add_res, sub_res, or_res, orn_res, and_res, andn_res, xor_res, xnor_res, sll_res, srl_res, sra_res, eq_res, lts_res, ltu_res, clz_res, ctz_res, cpop_res, rol_res, ror_res, signextb_res, signexth_res, mul_res, mulhs_res, mulhsu_res, mulhu_res, divs_res, divu_res, rems_res, remu_res, res_s :
      STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
BEGIN

   -- sabiranje
   add_res <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
   -- oduzimanje
   sub_res <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
   -- bitovski and
   and_res <= a_i and b_i;
   -- andn = rs1 and not rs2
   andn_res <= a_i and (not b_i);
   -- bitovski xor
   xor_res <= a_i xor b_i;
   -- bitovski or
   or_res <= a_i or b_i;
   -- orn = rs1 or not rs2
   orn_res <= a_i or (not b_i);
   -- xnor = not(rs1 xor rs2)
   xnor_res <= not (a_i xor b_i);
   -- sll koristi samo 5 nizih bita drugog operanda
   sll_res <= std_logic_vector(shift_left(unsigned(a_i), get_shift_amount(b_i(4 downto 0))));
   -- logicki pomjeraj udesno
   srl_res <= std_logic_vector(shift_right(unsigned(a_i), get_shift_amount(b_i(4 downto 0))));
   -- aritmeticki pomjeraj udesno cuva znak broja
   sra_res <= std_logic_vector(shift_right(signed(a_i), get_shift_amount(b_i(4 downto 0))));
   -- poredjenja vracaju 1 ako je uslov tacan, inace 0
   eq_res <= std_logic_vector(to_unsigned(1, WIDTH)) when a_i = b_i else
             (others => '0');
   lts_res <= std_logic_vector(to_unsigned(1, WIDTH)) when signed(a_i) < signed(b_i) else
              (others => '0');
   ltu_res <= std_logic_vector(to_unsigned(1, WIDTH)) when unsigned(a_i) < unsigned(b_i) else
              (others => '0');
   -- zbb operacije nad jednim operandom
   clz_res <= count_leading_zeros(a_i);
   ctz_res <= count_trailing_zeros(a_i);
   cpop_res <= count_population(a_i);
   -- rol i ror koriste samo 5 nizih bita drugog operanda
   rol_res <= rotate_left_simple(a_i, get_shift_amount(b_i(4 downto 0)));
   ror_res <= rotate_right_simple(a_i, get_shift_amount(b_i(4 downto 0)));
   -- sign extension iz manjeg dela registra
   signextb_res <= sign_extend_byte(a_i);
   signexth_res <= sign_extend_halfword(a_i);
   -- M prosirenje
   mul_res <= multiply_lower(a_i, b_i);
   mulhs_res <= multiply_high_signed(a_i, b_i);
   mulhsu_res <= multiply_high_signed_unsigned(a_i, b_i);
   mulhu_res <= multiply_high_unsigned(a_i, b_i);
   divs_res <= divide_signed_simple(a_i, b_i);
   divu_res <= divide_unsigned_simple(a_i, b_i);
   rems_res <= reminder_signed_simple(a_i, b_i);
   remu_res <= reminder_unsigned_simple(a_i, b_i);

   -- izbor rezultata
   res_o <= res_s;
   with op_i select
      res_s <= and_res  when and_op,
               or_res   when or_op,
               xor_res  when xor_op,
               add_res  when add_op,
               sub_res  when sub_op,
               eq_res   when eq_op,
               lts_res  when lts_op,
               ltu_res  when ltu_op,
               sll_res  when sll_op,
               srl_res  when srl_op,
               sra_res  when sra_op,
               andn_res when andn_op,
               orn_res  when orn_op,
               xnor_res when xnor_op,
               clz_res  when clz_op,
               ctz_res  when ctz_op,
               cpop_res when cpop_op,
               rol_res  when rol_op,
               ror_res  when ror_op,
               signextb_res when signextb_op,
               signexth_res when signexth_op,
               mul_res  when mulu_op,
               mulhs_res when mulhs_op,
               mulhsu_res when mulhsu_op,
               mulhu_res when mulhu_op,
               divs_res when divs_op,
               divu_res when divu_op,
               rems_res when rems_op,
               remu_res when remu_op,
               (others => '1') when others;

   -- Postavlja zero_o na 1 ukoliko je rezultat operacije 0
   zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0, WIDTH)) else
             '0';

   -- Prekoracenje se desava kada ulazi imaju isti znak, a izlaz razlicit.
   of_o <= '1' when ((op_i = add_op and (a_i(WIDTH-1) = b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1)) = '1')) or
                     (op_i = sub_op and (a_i(WIDTH-1) /= b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1)) = '1'))) else
           '0';

END behavioral;
