# Vivado uputstvo za pokretanje

Ovo je kratko GUI uputstvo za projekat `RISCV_VHDL_Zbb`.

## 1. Pravljenje Vivado projekta

1. Otvoriti Vivado.
2. Izabrati:

```text
Tools -> Run Tcl Script...
```

3. Izabrati fajl:

```text
RISCV.tcl
```

Skripta sama pravi projekat:

```text
rv32i/vivado_projekat/vivado_projekat.xpr
```

Skripta ne koristi lokalne `C:/Users/...` putanje. Sve putanje racuna relativno
od mjesta gdje se nalazi `RISCV.tcl`.

## 2. Pokretanje simulacije kroz GUI

Kada se projekat napravi i otvori:

```text
Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation
```

Podrazumijevani scenario je Zbb demo:

```text
SCENARIO_ID_G=1
PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt
```

Ocekivana poruka u Tcl konzoli:

```text
Note: Zbb CPU demo test passed
```

## 3. Rucno prebacivanje scenarija u Tcl konzoli

RV32I regresija:

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=0 PROGRAM_PATH_G=../../../../../testovi/test_programi/rv32i_regression.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Zbb demo:

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=1 PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Prosireni demo:

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=2 PROGRAM_PATH_G=../../../../../testovi/test_programi/extended_demo.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Ocekivane pass poruke:

```text
Note: rv32i regression CPU test passed
Note: Zbb CPU demo test passed
Note: Extended CPU demo test passed
```

## 4. Sta screenshotovati

Najbolje je screenshotovati Tcl konzolu gdje se vidi pass poruka. Ako se trazi
waveform, u `TOP_testovi` dodati signale:

```text
clk
reset
addrb_instr_32_s
instr_mem_cpu_s
wea_data_s
addra_data_32_s
dina_data_s
```

Radix podesiti na hexadecimal. Korisni krajevi scenarija su:

- Zbb demo: `addr=0x00000044 data=0xFFFFF000`
- prosireni demo: `addr=0x00000100 data=0x000001E4`
