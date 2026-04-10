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

   signal add_res, sub_res, or_res, orn_res, and_res, andn_res, xnor_res, clz_res, ctz_res, cpop_res, rol_res, ror_res, res_s :
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
   -- bitovski or
   or_res <= a_i or b_i;
   -- orn = rs1 or not rs2
   orn_res <= a_i or (not b_i);
   -- xnor = not(rs1 xor rs2)
   xnor_res <= not (a_i xor b_i);
   -- zbb operacije nad jednim operandom
   clz_res <= count_leading_zeros(a_i);
   ctz_res <= count_trailing_zeros(a_i);
   cpop_res <= count_population(a_i);
   -- rol i ror koriste samo 5 nizih bita drugog operanda
   rol_res <= rotate_left_simple(a_i, get_shift_amount(b_i(4 downto 0)));
   ror_res <= rotate_right_simple(a_i, get_shift_amount(b_i(4 downto 0)));

   -- izbor rezultata
   res_o <= res_s;
   with op_i select
      res_s <= and_res  when and_op,
               or_res   when or_op,
               add_res  when add_op,
               sub_res  when sub_op,
               andn_res when andn_op,
               orn_res  when orn_op,
               xnor_res when xnor_op,
               clz_res  when clz_op,
               ctz_res  when ctz_op,
               cpop_res when cpop_op,
               rol_res  when rol_op,
               ror_res  when ror_op,
               (others => '1') when others;

   -- Postavlja zero_o na 1 ukoliko je rezultat operacije 0
   zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0, WIDTH)) else
             '0';

   -- Prekoracenje se desava kada ulazi imaju isti znak, a izlaz razlicit.
   of_o <= '1' when ((op_i = add_op and (a_i(WIDTH-1) = b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1)) = '1')) or
                     (op_i = sub_op and (a_i(WIDTH-1) /= b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1)) = '1'))) else
           '0';

END behavioral;
