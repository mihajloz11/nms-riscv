# Vivado uputstvo za pokretanje i dokaz rada

Ovo uputstvo vazi za projekat:

`NMS/projekat/RISCV_VHDL_Zbb`

## 1. Najbrza kompletna provjera

Iz root foldera projekta pokrenuti:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_vivado_checks.ps1 -Scenario all
```

Ova komanda automatski:

- regenerise Vivado projekat iz `RISCV.tcl`
- pokrece sintezu za `TOP_RISCV`
- pokrece behavioral simulaciju za `ALU_zbb_tb`
- pokrece CPU testbench `TOP_testovi` za Zbb demo
- pokrece CPU testbench `TOP_testovi` za RV32I regresiju
- pokrece CPU testbench `TOP_testovi` za prosireni demo

Ako sve radi, u Tcl konzoli / logu treba da se vide ove linije:

```text
SYNTH_STATUS=synth_design Complete!
Note: ALU extended tests passed
Note: Zbb CPU demo test passed
Note: rv32i regression CPU test passed
Note: Extended CPU demo test passed
Vivado checks completed successfully.
```

Ovo je najjaci dokaz, jer testbench ne samo da zavrsi simulaciju nego poredi
svaku store adresu i svaki store podatak sa ocekivanim vrijednostima. Ako nesto
nije tacno, simulacija se prekida sa `assert failure`.

## 2. Otvaranje projekta u Vivado GUI-u

1. Otvoriti Vivado 2025.2.
2. Izabrati `Open Project`.
3. Otvoriti fajl:

```text
NMS/projekat/RISCV_VHDL_Zbb/rv32i/vivado_projekat/vivado_projekat.xpr
```

4. Ako Vivado prikaze upozorenje o dugoj putanji, moze se nastaviti. To nije
greska u VHDL projektu.
5. U lijevom panelu `Flow Navigator` izabrati:

```text
Simulation -> Run Simulation -> Run Behavioral Simulation
```

Podrazumijevani GUI scenario je Zbb demo:

```text
SCENARIO_ID_G=1
PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt
```

Za taj scenario u Tcl konzoli treba da se pojavi:

```text
Note: Zbb CPU demo test passed
```

## 3. Pokretanje drugih scenarija iz Vivado Tcl konzole

Ako hoces iz GUI-a rucno pokrenuti pojedinacne scenarije, najjednostavnije je
koristiti Tcl konzolu.

### RV32I regresija

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=0 PROGRAM_PATH_G=../../../../../testovi/test_programi/rv32i_regression.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Ocekivani dokaz:

```text
Note: rv32i regression CPU test passed
```

### Zbb demo

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=1 PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Ocekivani dokaz:

```text
Note: Zbb CPU demo test passed
```

### Prosireni demo

```tcl
set_property top TOP_testovi [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=2 PROGRAM_PATH_G=../../../../../testovi/test_programi/extended_demo.txt} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
restart
run all
```

Ocekivani dokaz:

```text
Note: Extended CPU demo test passed
```

## 4. Sta screenshotovati

Najbolje je screenshotovati Tcl konzolu, jer ona direktno pokazuje da su prosli
sinteza i svi testbench scenariji. Ako treba samo jedan screenshot, uzeti dio
konzole gdje se vide:

```text
SYNTH_STATUS=synth_design Complete!
Note: ALU extended tests passed
Note: Zbb CPU demo test passed
Note: rv32i regression CPU test passed
Note: Extended CPU demo test passed
Vivado checks completed successfully.
```

Ako profesor trazi i waveform dokaz, onda screenshot nije obavezan za ispravnost,
ali moze pomoci da se vidi rad procesora. U waveform prozor dodati ove signale iz
`TOP_testovi`:

```text
clk
reset
addrb_instr_32_s
instr_mem_cpu_s
wea_data_s
addra_data_32_s
dina_data_s
```

Radix podesiti na hexadecimal. Screenshot ima smisla napraviti na kraju Zbb demo
simulacije ili prosirenog demo scenarija, na mjestu gdje je `wea_data_s` razlicito
od nule, jer tada procesor upisuje rezultat u data memoriju.

Primjeri korisnih vrijednosti:

- Zbb demo na kraju ima store `addr=0x00000044 data=0xFFFFF000`
- prosireni demo na kraju ima store `addr=0x00000100 data=0x000001E4`

Ipak, za odbranu je Tcl konzola jaci dokaz od samog waveform screenshot-a, jer
pass poruke dolaze tek poslije automatskog poredjenja rezultata.

## 5. Sta reci ako pitaju zasto nema vise screenshotova

Moze se reci:

```text
Glavni dokaz je Tcl konzola, jer testbench automatski provjerava ocekivane store
adrese i podatke. Waveform se moze koristiti kao vizuelni dodatak, ali nije
neophodan za dokaz ispravnosti jer bi pogresan rezultat izazvao assert failure.
```
