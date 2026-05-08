library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ops_pkg.all;

entity alu_decoder is
   port (
      -- ulazi iz kontrole
      alu_2bit_op_i : in std_logic_vector(1 downto 0);
      -- polja instrukcije
      funct3_i : in std_logic_vector(2 downto 0);
      funct7_i : in std_logic_vector(6 downto 0);
      funct12_i : in std_logic_vector(11 downto 0);
      -- izlazi ka datapath-u
      alu_op_o : out std_logic_vector(4 downto 0));
end entity;

architecture behavioral of alu_decoder is
begin

   -- bira alu operaciju za trenutnu instrukciju
   alu_dec : process(alu_2bit_op_i, funct3_i, funct7_i, funct12_i) is
   begin
      alu_op_o <= "00000"; -- podrazumevana vrednost

      case alu_2bit_op_i is
         when "00" =>
            alu_op_o <= add_op;
         when "01" =>
            alu_op_o <= eq_op;
         when others =>
            if (alu_2bit_op_i = "10" and funct7_i = "0000001") then
               case funct3_i is
                  when "000" =>
                     alu_op_o <= mulu_op;
                  when "001" =>
                     alu_op_o <= mulhs_op;
                  when "010" =>
                     alu_op_o <= mulhsu_op;
                  when "011" =>
                     alu_op_o <= mulhu_op;
                  when "100" =>
                     alu_op_o <= divs_op;
                  when "101" =>
                     alu_op_o <= divu_op;
                  when "110" =>
                     alu_op_o <= rems_op;
                  when "111" =>
                     alu_op_o <= remu_op;
                  when others =>
                     alu_op_o <= add_op;
               end case;
            else
               case funct3_i is
                  when "000" =>
                     alu_op_o <= add_op;
                     if (alu_2bit_op_i = "10" and funct7_i(5) = '1') then
                        alu_op_o <= sub_op;
                     end if;
                  when "010" =>
                     alu_op_o <= lts_op;
                  when "011" =>
                     alu_op_o <= ltu_op;
                  when "110" =>
                     alu_op_o <= or_op;
                     if (alu_2bit_op_i = "10" and funct7_i = "0100000") then
                        alu_op_o <= orn_op;
                     end if;
                  when "111" =>
                     alu_op_o <= and_op;
                     if (alu_2bit_op_i = "10" and funct7_i = "0100000") then
                        alu_op_o <= andn_op;
                     end if;
                  when "100" =>
                     alu_op_o <= xor_op;
                     if (alu_2bit_op_i = "10" and funct7_i = "0100000") then
                        alu_op_o <= xnor_op;
                     end if;
                  when "001" =>
                     if (alu_2bit_op_i = "11") then
                        case funct12_i is
                           when x"600" =>
                              alu_op_o <= clz_op;
                           when x"601" =>
                              alu_op_o <= ctz_op;
                           when x"602" =>
                              alu_op_o <= cpop_op;
                           when x"604" =>
                              alu_op_o <= signextb_op;
                           when x"605" =>
                              alu_op_o <= signexth_op;
                           when others =>
                              alu_op_o <= sll_op;
                        end case;
                     elsif (alu_2bit_op_i = "10" and funct7_i = "0110000") then
                        alu_op_o <= rol_op;
                     else
                        alu_op_o <= sll_op;
                     end if;
                  when "101" =>
                     alu_op_o <= srl_op;
                     if (alu_2bit_op_i = "10" and funct7_i = "0110000") then
                        alu_op_o <= ror_op;
                     elsif (alu_2bit_op_i = "11" and funct7_i = "0110000") then
                        alu_op_o <= ror_op;
                     elsif (funct7_i = "0100000") then
                        alu_op_o <= sra_op;
                     end if;
                  when others =>
                     alu_op_o <= add_op;
               end case;
            end if;
      end case;
   end process;

end architecture;
