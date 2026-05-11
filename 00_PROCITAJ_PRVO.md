# Napredni mikroprocesorski sistemi - sta je sta

Ovaj workspace je ociscen tako da ostanu samo bitne stvari za projekat i ucenje.

## Folderi

- `01_PREDAVANJA_I_MATERIJALI/` - PDF predavanja i materijali sa vjezbi
- `02_REFERENTNI_KOD_I_RV32I_BAZA/` - referentni Git kod i originalna RV32I baza iz vjezbi
- `03_PROJEKAT_RISCV_VHDL_ZBB/` - glavni projekat za RISC-V VHDL prosirenje instrukcija
- `04_UCENJE/` - komentarisani kod, pitanja/odgovori i materijal za odbranu
- `05_FINALNO_ZA_PREDAJU/` - finalni Word report, Vivado/GHDL dokazni logovi i kratko uputstvo

## Sta slati profesoru

Najcistije je slati:

- `03_PROJEKAT_RISCV_VHDL_ZBB/`
- `05_FINALNO_ZA_PREDAJU/`

U glavnom projektu nema gotovog Vivado `.xpr` sa lokalnim putanjama. Profesor u Vivadu pokrene `RISCV.tcl`, a skripta sama napravi projekat i doda sve VHDL fajlove.

## Brza provjera

GHDL provjera:

```powershell
cd .\03_PROJEKAT_RISCV_VHDL_ZBB
powershell -ExecutionPolicy Bypass -File .\scripts\run_ghdl_tests.ps1 -Scenario all
```

Vivado GUI:

```text
Tools -> Run Tcl Script... -> RISCV.tcl
Simulation -> Run Simulation -> Run Behavioral Simulation
```

Detaljnija mapa projekta je u:

```text
03_PROJEKAT_RISCV_VHDL_ZBB\mapa_projekta.md
```
