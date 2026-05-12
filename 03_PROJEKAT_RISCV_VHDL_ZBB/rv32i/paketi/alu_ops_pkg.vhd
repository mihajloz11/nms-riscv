library ieee;
use ieee.std_logic_1164.all;

package alu_ops_pkg is

   -- interni kodovi za alu
   constant and_op : std_logic_vector(4 downto 0) := "00000";
   constant or_op : std_logic_vector(4 downto 0) := "00001";
   constant xor_op : std_logic_vector(4 downto 0) := "00011";
   constant add_op : std_logic_vector(4 downto 0) := "00010";
   constant sub_op : std_logic_vector(4 downto 0) := "00110";
   constant eq_op : std_logic_vector(4 downto 0) := "10111";
   constant lts_op : std_logic_vector(4 downto 0) := "10100"; -- manje, signed
   constant ltu_op : std_logic_vector(4 downto 0) := "10101"; -- manje, unsigned
   constant sll_op : std_logic_vector(4 downto 0) := "10110"; -- pomjeraj lijevo
   constant srl_op : std_logic_vector(4 downto 0) := "00111"; -- logicki desno
   constant sra_op : std_logic_vector(4 downto 0) := "01000"; -- aritmeticki desno
   constant andn_op : std_logic_vector(4 downto 0) := "10001"; -- and sa negiranim rs2
   constant orn_op : std_logic_vector(4 downto 0) := "00101"; -- or sa negiranim rs2
   constant xnor_op : std_logic_vector(4 downto 0) := "11000";
   constant clz_op : std_logic_vector(4 downto 0) := "10010"; -- broj nula s lijeva
   constant ctz_op : std_logic_vector(4 downto 0) := "10011"; -- broj nula s desna
   constant cpop_op : std_logic_vector(4 downto 0) := "00100";
   constant rol_op : std_logic_vector(4 downto 0) := "11001";
   constant ror_op : std_logic_vector(4 downto 0) := "11010";
   constant signextb_op : std_logic_vector(4 downto 0) := "11011"; -- prosirenje bajta
   constant signexth_op : std_logic_vector(4 downto 0) := "11100"; -- prosirenje polurijeci
   constant mulu_op : std_logic_vector(4 downto 0) := "01001"; -- nizi dio mnozenja
   constant mulhs_op : std_logic_vector(4 downto 0) := "01010"; -- visi dio signed mnozenja
   constant mulhsu_op : std_logic_vector(4 downto 0) := "01011"; -- signed i unsigned mnozenje
   constant mulhu_op : std_logic_vector(4 downto 0) := "01100"; -- visi dio unsigned mnozenja
   constant divu_op : std_logic_vector(4 downto 0) := "01101"; -- unsigned dijeljenje
   constant divs_op : std_logic_vector(4 downto 0) := "01110"; -- signed dijeljenje
   constant remu_op : std_logic_vector(4 downto 0) := "01111"; -- unsigned ostatak
   constant rems_op : std_logic_vector(4 downto 0) := "10000"; -- signed ostatak

end package alu_ops_pkg;
