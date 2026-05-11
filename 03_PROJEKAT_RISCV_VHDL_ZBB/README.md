# RV32IM single-cycle + Zbb podskup

Ovo je skolski single-cycle RISC-V projekat prosiren sa dodatnim RV32I instrukcijama, RV32M skupom i manjim Zbb podskupom. Kod je namjerno ostavljen jednostavan i citljiv, da se moze lako proci kroz dekodere, ALU i datapath.

## Sta je dodato

- dodatni RV32I: `lui`, `auipc`, `jal`, `jalr`, svi branch uslovi, load/store varijante, I/R ALU operacije, `fence`, `ecall`, `ebreak`
- RV32M: `mul`, `mulh`, `mulhsu`, `mulhu`, `div`, `divu`, `rem`, `remu`
- Zbb podskup: `andn`, `orn`, `xnor`, `clz`, `ctz`, `cpop`, `rol`, `ror`, `sext.b`, `sext.h`

## Najbitnije u projektu

- `rv32i/` - VHDL implementacija procesora, kontrola, datapath, paketi i testovi
- `RISCV.tcl` - prenosiva Vivado GUI skripta koja pravi `rv32i/vivado_projekat/vivado_projekat.xpr`
- `scripts/run_ghdl_tests.ps1` - jedna GHDL skripta za pokretanje svih testova
- `output/` - finalni Word report i posljednji dokazni logovi
- `mapa_projekta.md` - kratak vodic kroz strukturu projekta

## Vivado GUI

U Vivadu pokrenuti:

```text
Tools -> Run Tcl Script... -> RISCV.tcl
```

Skripta nema lokalne Windows putanje. Sama nalazi folder projekta, doda sve VHDL fajlove i napravi `rv32i/vivado_projekat/vivado_projekat.xpr`.

Nakon toga se simulacija moze pokrenuti normalno kroz GUI:

```text
Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation
```

Podrazumijevani scenario je Zbb demo.

## GHDL provjera

Iz root foldera projekta:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_ghdl_tests.ps1 -Scenario all
```

Skripta kompajlira VHDL fajlove i pokrece:

- ALU/Zbb test
- Zbb CPU demo
- prosireni CPU demo
- RV32I regresioni test

Dokazni log se cuva u `output/ghdl_latest.log`.

## Dokumentacija i dokazi

- `output/projektna_dokumentacija_rv32im_zbb.docx` - finalni Word report u repou
- `output/vivado_latest.log` - posljednji Vivado dokaz
- `output/ghdl_latest.log` - posljednji GHDL dokaz
- `output/vivado_uputstvo_za_pokretanje_2026-05-09.md` - kratko uputstvo za Vivado provjeru

Generisani Vivado folderi, `.Xil`, `tmp`, waveform/log cache i stari XPR fajlovi nisu dio finalnog projekta za slanje.
