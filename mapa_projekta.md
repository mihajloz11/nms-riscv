# Mapa projekta

Ovo je kratka mapa da se brzo vidi sta je sta u finalnom projektu za slanje.

```text
RISCV_VHDL_Zbb/
|-- README.md
|-- RISCV.tcl
|-- mapa_projekta.md
|-- rv32i/
|   |-- TOP_RISCV.vhd
|   |-- kontrola/
|   |-- podaci/
|   |-- paketi/
|   `-- testovi/
|-- scripts/
|   `-- run_ghdl_tests.ps1
`-- output/
    |-- projektna_dokumentacija_rv32im_zbb.docx
    |-- vivado_latest.log
    |-- ghdl_latest.log
    `-- vivado_uputstvo_za_pokretanje_2026-05-09.md
```

## Sta je izvorni procesor

Polazna osnova je single-cycle RV32I procesor iz vjezbe 2. Osnovna ideja je zadrzana:

- `TOP_RISCV.vhd` spaja kontrolu, datapath i memorijske interfejse
- `kontrola/` dekoduje instrukciju i bira kontrolne signale
- `podaci/` sadrzi PC, registarsku banku, immediate, ALU i mux logiku
- `testovi/` sadrzi memoriju i testbench

Originalni mali skup iz vjezbe je bio:

```text
lw   sw   add   sub   and   or   beq   addi
```

## Gdje su glavne izmjene

- `rv32i/kontrola/ctrl_decoder.vhd` - prosireni opcode-i i osnovni kontrolni signali
- `rv32i/kontrola/alu_decoder.vhd` - prepoznavanje RV32I, RV32M i Zbb ALU operacija
- `rv32i/kontrola/kontrola.vhd` - izbor PC-a, branch/jump logika i store byte-enable
- `rv32i/podaci/ALU_simple.vhd` - implementacija novih ALU, RV32M i Zbb operacija
- `rv32i/podaci/podaci.vhd` - PC mux, branch provjera, load prosirenje i izbor upisa u registar
- `rv32i/podaci/immediate.vhd` - dodati U i J immediate formati
- `rv32i/paketi/alu_ops_pkg.vhd` - interni ALU kodovi

## Testovi

- `rv32i/testovi/ALU_zbb_tb.vhd` - direktna provjera ALU/Zbb operacija
- `rv32i/testovi/TOP_testovi.vhd` - CPU testbench koji prati store operacije i poredi ih sa ocekivanim rezultatima
- `rv32i/testovi/test_programi/rv32i_regression.txt` - regresija osnovnih RV32I instrukcija
- `rv32i/testovi/test_programi/zbb_demo.txt` - Zbb demo
- `rv32i/testovi/test_programi/extended_demo.txt` - siri demo sa RV32I, RV32M, Zbb, grananjem, skokovima i memorijom

## Kako otvoriti u Vivadu

Pokrenuti `RISCV.tcl` iz Vivado GUI:

```text
Tools -> Run Tcl Script... -> RISCV.tcl
```

Skripta pravi `rv32i/vivado_projekat/vivado_projekat.xpr`. Taj folder je generisan i ne mora se slati ako profesor pokrece Tcl skriptu.

## Kako pokrenuti GHDL dokaz

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_ghdl_tests.ps1 -Scenario all
```

Log prolaza se cuva u `output/ghdl_latest.log`.
