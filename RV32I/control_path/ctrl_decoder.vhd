library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_decoder is
   port (
      --************ Opcode polje instrukcije************
      opcode_i      : in  std_logic_vector (6 downto 0);
      --************ Kontrolni signali*******************
      branch_o      : out std_logic;
      mem_to_reg_o  : out std_logic;
      data_mem_we_o : out std_logic;
      alu_src_o     : out std_logic;
      alu_src_a_o   : out std_logic_vector(1 downto 0);
      rd_src_o      : out std_logic_vector(1 downto 0);
      rd_we_o       : out std_logic;
      alu_2bit_op_o : out std_logic_vector(1 downto 0);
      jump_o        : out std_logic;
      jalr_o        : out std_logic
      );
end entity;

architecture behavioral of ctrl_decoder is
   constant LOAD_OPCODE_C   : std_logic_vector(4 downto 0) := "00000";
   constant MISC_MEM_OPCODE_C : std_logic_vector(4 downto 0) := "00011";
   constant AUIPC_OPCODE_C  : std_logic_vector(4 downto 0) := "00101";
   constant STORE_OPCODE_C  : std_logic_vector(4 downto 0) := "01000";
   constant R_TYPE_OPCODE_C : std_logic_vector(4 downto 0) := "01100";
   constant LUI_OPCODE_C    : std_logic_vector(4 downto 0) := "01101";
   constant I_TYPE_OPCODE_C : std_logic_vector(4 downto 0) := "00100";
   constant B_TYPE_OPCODE_C : std_logic_vector(4 downto 0) := "11000";
   constant JALR_OPCODE_C   : std_logic_vector(4 downto 0) := "11001";
   constant JAL_OPCODE_C    : std_logic_vector(4 downto 0) := "11011";
   constant SYSTEM_OPCODE_C : std_logic_vector(4 downto 0) := "11100";
begin

   control_dec : process(opcode_i)is
   begin
      --***Podrazumevane vrednost***
      branch_o      <= '0';
      mem_to_reg_o  <= '0';
      data_mem_we_o <= '0';
      alu_src_o     <= '0';
      alu_src_a_o   <= "00";
      rd_src_o      <= "00";
      rd_we_o       <= '0';
      alu_2bit_op_o <= "00";
      jump_o        <= '0';
      jalr_o        <= '0';
      --****************************      
      case opcode_i(6 downto 2) is
         when LOAD_OPCODE_C =>          --LOAD: lw, lb, lbu
            alu_2bit_op_o <= "00";
            mem_to_reg_o  <= '1';
            rd_src_o      <= "01";
            alu_src_o     <= '1';
            rd_we_o       <= '1';
         when MISC_MEM_OPCODE_C =>      --MISC MEM: fence kao no-op
            null;
         when AUIPC_OPCODE_C =>         --AUIPC: rd = pc + immediate
            alu_2bit_op_o <= "00";
            alu_src_a_o   <= "01";
            alu_src_o     <= '1';
            rd_we_o       <= '1';
         when STORE_OPCODE_C =>         --STORE: sw, sb
            alu_2bit_op_o <= "00";
            data_mem_we_o <= '1';
            alu_src_o     <= '1';
         when R_TYPE_OPCODE_C =>        --R type: add, sub, and, or, xor...
            alu_2bit_op_o <= "10";
            rd_we_o       <= '1';
         when LUI_OPCODE_C =>           --LUI: rd = immediate
            alu_2bit_op_o <= "00";
            alu_src_a_o   <= "10";
            alu_src_o     <= '1';
            rd_we_o       <= '1';
         when I_TYPE_OPCODE_C =>        --I type: addi, xori, slli, clz...
            alu_2bit_op_o <= "11";
            alu_src_o     <= '1';
            rd_we_o       <= '1';
         when B_TYPE_OPCODE_C =>        --B type: beq, bne, blt, bge
            alu_2bit_op_o <= "01";
            branch_o      <= '1';
         when JALR_OPCODE_C =>          --JALR: rd = pc + 4, pc = rs1 + immediate
            alu_2bit_op_o <= "00";
            alu_src_o     <= '1';
            rd_src_o      <= "10";
            rd_we_o       <= '1';
            jalr_o        <= '1';
         when JAL_OPCODE_C =>           --JAL: rd = pc + 4, pc = pc + immediate
            rd_src_o      <= "10";
            rd_we_o       <= '1';
            jump_o        <= '1';
         when SYSTEM_OPCODE_C =>        --SYSTEM: ecall i ebreak kao no-op
            null;
         when others =>
            null;
      end case;
   end process;

end architecture;
