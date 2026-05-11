# Sta je dodano u zavrsnoj provjeri

Dodano je nekoliko stvari da projekat ima jasniji dokaz rada i lakse pokretanje u Vivadu.

## Dokumentacija

- `output/NMS_RISCV_Zbb_REPORT_TESTIRANO_FINAL.docx`
  - finalni Word report
  - u sekciji 8.1 dodat je izvod iz Vivado Tcl konzole kao dokaz
  - konzolni output je formatiran drugim fontom da se razlikuje od obicnog teksta

- `output/vivado_uputstvo_za_pokretanje_2026-05-09.md`
  - kratko uputstvo kako otvoriti projekat u Vivadu
  - sadrzi batch komandu za kompletnu provjeru
  - sadrzi sta treba screenshotovati kao dokaz

- `output/00_PROCITAJ_OUTPUT.txt`
  - kratak opis koji output fajlovi su bitni

## Skripte za provjeru

- `scripts/run_vivado_checks.ps1`
  - PowerShell wrapper za Vivado batch provjeru
  - koristi Vivado 2025.2 sa putanje `C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat`

- `scripts/vivado_run_checks.tcl`
  - regenerise Vivado projekat iz `RISCV.tcl`
  - pokrece sintezu
  - pokrece behavioral simulacije za:
    - `ALU_zbb_tb`
    - Zbb CPU demo
    - RV32I regresiju
    - prosireni CPU demo

## Log dokazi

- `output/vivado_all_2026-05-09.log`
  - kompletan Vivado log
  - u njemu se vide:
    - `SYNTH_STATUS=synth_design Complete!`
    - `ALU extended tests passed`
    - `Zbb CPU demo test passed`
    - `rv32i regression CPU test passed`
    - `Extended CPU demo test passed`
    - `Vivado checks completed successfully.`

- `output/ghdl_all_2026-05-09.log`
  - GHDL log za dodatnu provjeru
  - zavrsava porukom da su trazeni GHDL testovi prosli

## README dopuna

U `README.md` je dodat kratak dio kako se pokrece kompletna Vivado batch provjera.
