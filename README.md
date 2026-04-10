# RV32I single-cycle + Zbb podskup

Ovaj projekat je radjen nad postojecom single-cycle RV32I bazom iz materijala za predmet Napredni mikroprocesorski sistemi.
Osnovna arhitektura je prosirena manjim podskupom standardnih RISC-V bit-manipulation instrukcija.

Implementirane instrukcije:
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

Kako otvoriti projekat u Vivado:
- otvori `RV32I/RISCV_project/RISCV_project.xpr`
- pokreni `Run Behavioral Simulation`
- podrazumevani waveform je vec pripremljen za Zbb demo scenario

Sta je provereno:
- GHDL simulacija za nove instrukcije
- CPU-level simulacija za Zbb demo
- regresiona provera osnovnih RV32I instrukcija
- Vivado/XSim behavioral simulacija
- Vivado synthesis

Napomena:
- projekat je radjen nad single-cycle bazom, ne nad pipelined varijantom
- fokus rada je na jasnom prosirenju instruction set-a, bez nepotrebnog komplikovanja arhitekture
