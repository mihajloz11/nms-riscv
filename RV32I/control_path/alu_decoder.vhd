library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_ops_pkg.all;

entity alu_decoder is
   port (
      --******** Controlpath ulazi *********
      alu_2bit_op_i : in  std_logic_vector(1 downto 0);
      --******** Polja instrukcije *******
      funct3_i      : in  std_logic_vector (2 downto 0);
      funct7_i      : in  std_logic_vector (6 downto 0);
      funct12_i     : in  std_logic_vector (11 downto 0);
      --******** Datapath izlazi ********
      alu_op_o      : out std_logic_vector(4 downto 0));
end entity;

architecture behavioral of alu_decoder is
begin

   --Kombinaciona logika koja na osnovu informacije iz ctrl_decoder
   --modula postavlja alu_op_o na odredjenu vrednost, pri cemu ta
   --vrednost predstavlja zeljenu operaciju.
   alu_dec : process(alu_2bit_op_i, funct3_i, funct7_i, funct12_i)is
   begin
      alu_op_o <= "00000";              --Podrazumevana vrednost

      case alu_2bit_op_i is
         when "00" =>
            alu_op_o <= add_op;
         when "01" =>
            alu_op_o <= eq_op;
         when others =>
            case funct3_i is
               when "000" =>
                  alu_op_o <= add_op;
                  if(alu_2bit_op_i = "10" and funct7_i(5) = '1')then
                     alu_op_o <= sub_op;
                  end if;
               when "110" =>
                  alu_op_o <= or_op;
               when "111" =>
                  alu_op_o <= and_op;
                  if (alu_2bit_op_i = "10" and funct7_i = "0100000") then
                     alu_op_o <= andn_op;
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
                        when others =>
                           alu_op_o <= add_op;
                     end case;
                  else
                     alu_op_o <= and_op;
                  end if;
               when others =>
                  alu_op_o <= and_op;
            end case;
      end case;
   end process;

end architecture;
