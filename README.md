# RV32IM single-cycle + Zbb podskup

Ovaj projekat je radjen nad postojecom single-cycle RV32I bazom iz materijala za predmet Napredni mikroprocesorski sistemi.
Osnovna arhitektura je prosirena manjim podskupom standardnih RISC-V bit-manipulation instrukcija,
a zatim i dodatnim RV32I instrukcijama koje lepo staju u postojeci single-cycle model.

Dodate RV32M instrukcije:
- `mul`
- `mulh`
- `mulhsu`
- `mulhu`
- `div`
- `divu`
- `rem`
- `remu`

Dodate Zbb instrukcije:
- `andn`
- `orn`
- `xnor`
- `clz`
- `ctz`
- `cpop`
- `rol`
- `ror`
- `sign-extend byte (sext.b)`
- `sign-extend halfword (sext.h)`

Podrzan RV32I skup:
- `lui`
- `auipc`
- `jal`
- `jalr`
- `beq`
- `bne`
- `blt`
- `bge`
- `bltu`
- `bgeu`
- `lb`
- `lh`
- `lw`
- `lbu`
- `lhu`
- `sb`
- `sh`
- `sw`
- `addi`
- `slti`
- `sltiu`
- `xori`
- `ori`
- `andi`
- `slli`
- `srli`
- `srai`
- `add`
- `sub`
- `sll`
- `slt`
- `sltu`
- `xor`
- `srl`
- `sra`
- `or`
- `and`
- `fence`
- `ecall`
- `ebreak`

Ukupno stanje projekta:
- kompletan osnovni RV32I skup: 40 instrukcija
- dodat RV32M skup: 8 instrukcija
- dodat Zbb podskup: 10 instrukcija
- ukupno dokumentovano u ovom projektu: 58 instrukcija

Osnovna ideja projekta:
- polazna baza je single-cycle RV32I procesor
- prosiren je dekoder instrukcija na isti jednostavan nacin kao u skolskom primeru
- prosirena je ALU logika bez uvodjenja nepotrebno slozenih blokova
- M instrukcije su dodate direktno u ALU, kombinaciono, sto je najjednostavnije za skolski single-cycle model
- provereno je da nove instrukcije rade
- provereno je da stare RV32I instrukcije nisu pokvarene

Najvazniji fajlovi:
- `RV32I/control_path/alu_decoder.vhd` - dekodiranje novih instrukcija
- `RV32I/control_path/control_path.vhd` - osnovna kontrola grananja, skokova i upisa u memoriju
- `RV32I/control_path/ctrl_decoder.vhd` - osnovni kontrolni signali
- `RV32I/data_path/ALU_simple.vhd` - implementacija novih ALU operacija
- `RV32I/data_path/data_path.vhd` - PC mux, load prosirenja i izbor podatka za upis u registar
- `RV32I/data_path/immediate.vhd` - I/S/B/U/J immediate prosirenje
- `RV32I/packages/alu_ops_pkg.vhd` - interni ALU kodovi
- `RV32I/RISCV_tb/ALU_zbb_tb.vhd` - jednostavan ALU testbench
- `RV32I/RISCV_tb/TOP_RISCV_tb.vhd` - CPU-level testbench
- `RV32I/RISCV_tb/test_programs/extended_demo.txt` - demo za dodatne RV32I/RV32M instrukcije i skokove

Kako otvoriti projekat u Vivado:
- otvori `RV32I/RISCV_project/RISCV_project.xpr`
- pokreni `Run Behavioral Simulation`
- podrazumevani waveform je vec pripremljen za Zbb demo scenario

Sta je provereno:
- GHDL simulacija za nove instrukcije
- CPU-level simulacija za Zbb demo
- CPU-level simulacija za prosireni demo sa granama, skokovima, memorijom, RV32M i sistemskim instrukcijama
- regresiona provera osnovnih RV32I instrukcija
- Vivado synthesis

Napomena za Vivado simulaciju:
- ako je Vivado GUI vec otvoren, XSim ume da zakljuca svoje log fajlove
- u tom slucaju GHDL simulacija prolazi normalno, a Vivado synthesis takodje prolazi

Napomena:
- projekat je radjen nad single-cycle bazom, ne nad pipelined varijantom
- fokus rada je na jasnom prosirenju instruction set-a, bez nepotrebnog komplikovanja arhitekture
- nisu implementirane sve RISC-V ekstenzije sa sajta; nisu ukljuceni F/D floating-point, A atomici, C compressed, V vector, CSR/privileged sistem
