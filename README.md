# RV32I single-cycle + Zbb podskup

Ovaj projekat je radjen nad postojecom single-cycle RV32I bazom iz materijala za predmet Napredni mikroprocesorski sistemi.
Osnovna arhitektura je prosirena manjim podskupom standardnih RISC-V bit-manipulation instrukcija,
a zatim i dodatnim RV32I instrukcijama koje lepo staju u postojeci single-cycle model.

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

Dodatno ubacene RV32I instrukcije:
- `xor`
- `xori`
- `slli`
- `bne`
- `blt`
- `bge`
- `lb`
- `lbu`
- `sb`
- `fence`
- `ecall`
- `ebreak`

Ukupno stanje projekta:
- originalna baza: 8 instrukcija
- ranije dodato: 10 Zbb instrukcija
- sada dodatno: 12 novih instrukcija
- ukupno podrzano u ovom projektu: 30 instrukcija

Osnovna ideja projekta:
- polazna baza je single-cycle RV32I procesor
- prosiren je dekoder instrukcija
- prosirena je ALU logika
- provereno je da nove instrukcije rade
- provereno je da stare RV32I instrukcije nisu pokvarene

Najvazniji fajlovi:
- `RV32I/control_path/alu_decoder.vhd` - dekodiranje novih instrukcija
- `RV32I/control_path/control_path.vhd` - prosledjivanje dodatnih polja instrukcije do ALU dekodera
- `RV32I/control_path/ctrl_decoder.vhd` - osnovni kontrolni signali
- `RV32I/data_path/ALU_simple.vhd` - implementacija novih ALU operacija
- `RV32I/packages/alu_ops_pkg.vhd` - interni ALU kodovi
- `RV32I/RISCV_tb/ALU_zbb_tb.vhd` - jednostavan ALU testbench
- `RV32I/RISCV_tb/TOP_RISCV_tb.vhd` - CPU-level testbench
- `RV32I/RISCV_tb/test_programs/extended_demo.txt` - demo za dodatnih 12 instrukcija

Kako otvoriti projekat u Vivado:
- otvori `RV32I/RISCV_project/RISCV_project.xpr`
- pokreni `Run Behavioral Simulation`
- podrazumevani waveform je vec pripremljen za Zbb demo scenario

Sta je provereno:
- GHDL simulacija za nove instrukcije
- CPU-level simulacija za Zbb demo
- CPU-level simulacija za prosireni demo sa granama, memorijom i sistemskim instrukcijama
- regresiona provera osnovnih RV32I instrukcija
- Vivado synthesis

Napomena za Vivado simulaciju:
- ako je Vivado GUI vec otvoren, XSim ume da zakljuca svoje log fajlove
- u tom slucaju GHDL simulacija prolazi normalno, a Vivado synthesis takodje prolazi

Napomena:
- projekat je radjen nad single-cycle bazom, ne nad pipelined varijantom
- fokus rada je na jasnom prosirenju instruction set-a, bez nepotrebnog komplikovanja arhitekture
