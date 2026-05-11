UCENJE FOLDER - NMS RISC-V PROJEKAT
==================================

Ovaj folder je didakticka kopija najbitnijih djelova projekta.
Glavni cilj mu je da:
- izdvoji fajlove koji su bili najbitniji za prosirenje procesora
- doda komentarisane kopije za lakse citanje i odbranu
- omoguci da se projekat cita kao prica: top -> control path -> data path -> ALU -> testbench

VAZNA NAPOMENA
--------------

- Za stvarno pokretanje koriste se fajlovi iz `RISCV_VHDL_Zbb/RV32I/...`.
- Fajlovi iz `ucenje/` sluze za citanje, objasnjavanje i pripremu za odbranu.
- Kod u komentarisanim kopijama prati logiku glavnog projekta; razlike su namjerne samo u komentarima i u nazivu fajla (`_komentarisano`).

1) STRUKTURA OVOG UCENJE FOLDERA
--------------------------------

- `vhdl_komentarisano/dizajn/`
  Glavni VHDL moduli koje treba razumjeti.

- `vhdl_komentarisano/simulacija/`
  Testbench i logika provjere rezultata.

- `test_programi_komentarisano/`
  Demo programi i tekstualna objasnjenja sta se u njima izvrsava.

2) STA JE OVDE POKRIVENO
------------------------

Kljucni top i datapath/control path fajlovi:
- `TOP_RISCV_komentarisano.vhd`
- `control_path_komentarisano.vhd`
- `ctrl_decoder_komentarisano.vhd`
- `alu_decoder_komentarisano.vhd`
- `data_path_komentarisano.vhd`
- `ALU_simple_komentarisano.vhd`
- `immediate_komentarisano.vhd`
- `alu_ops_pkg_komentarisano.vhd`

Simulacija:
- `TOP_RISCV_tb_komentarisano.vhd`

Programi:
- `zbb_demo_komentarisano.txt`
- `extended_demo_komentarisano.txt`
- `objasnjenje_demo_programa.txt`

3) PREPORUCENI REDOSLIJED UCENJA
--------------------------------

1. `ascii_sema_riscv_single_cycle_zbb.txt`
2. `TOP_RISCV_komentarisano.vhd`
3. `control_path_komentarisano.vhd`
4. `ctrl_decoder_komentarisano.vhd`
5. `alu_decoder_komentarisano.vhd`
6. `data_path_komentarisano.vhd`
7. `immediate_komentarisano.vhd`
8. `ALU_simple_komentarisano.vhd`
9. `alu_ops_pkg_komentarisano.vhd`
10. `TOP_RISCV_tb_komentarisano.vhd`
11. `objasnjenje_demo_programa.txt`

4) STA JE NAJBITNIJE ZA ODBRANU
-------------------------------

Ako neko pita:

"Gdje se vidi kako je procesor organizovan?"
- otvori `TOP_RISCV_komentarisano.vhd`

"Gdje se vidi dekodiranje instrukcija?"
- otvori `ctrl_decoder_komentarisano.vhd`
- otvori `alu_decoder_komentarisano.vhd`

"Gdje se vidi gdje su dodate nove Zbb instrukcije?"
- otvori `alu_ops_pkg_komentarisano.vhd`
- otvori `alu_decoder_komentarisano.vhd`
- otvori `ALU_simple_komentarisano.vhd`

"Gdje se vidi kako instrukcija prolazi kroz procesor?"
- otvori `data_path_komentarisano.vhd`
- otvori `control_path_komentarisano.vhd`

"Gdje se vidi verifikacija?"
- otvori `TOP_RISCV_tb_komentarisano.vhd`

"Gdje se vidi program koji stvarno testira instrukcije?"
- otvori `zbb_demo_komentarisano.txt`
- otvori `objasnjenje_demo_programa.txt`
