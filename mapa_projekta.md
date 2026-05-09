# mapa projekta

Ovaj dokument objasnjava sta se nalazi u projektu, sta je preuzeto iz materijala sa vjezbi, sta je dodato i gdje se u kodu nalaze bitne izmjene.

## izvorna baza

Kao polazna tacka koriscen je single-cycle RISC-V projekat iz laboratorijske vjezbe 2 sa predmeta Napredni mikroprocesorski sistemi.

Na stranici predmeta pise da se predmet izvodi na MAS smjeru Embeded sistemi i algoritmi i da se materijal za laboratorijske vjezbe sastoji od vjezbe 1, vjezbe 2, izvornog koda za vjezbu 2, vjezbe 3 i ostalih materijala:

- stranica predmeta: https://www.elektronika.ftn.uns.ac.rs/napredni-mikroprocesorski-sistemi/specifikacija/specifikacija-predmeta/
- vjezba 1: uvod u RISC-V procesor
- vjezba 2: single-cycle RISC-V
- izvorni kodovi za vjezbu 2: `V2_source_codes.zip`

U materijalu za vjezbu 2 pise da je cilj da se objasni hardverska implementacija single-cycle RISC-V procesora. Tamo je navedeno da se svaka instrukcija izvrsava u jednom taktu i da je takva arhitektura jednostavna i dobra za edukativne svrhe. U istom materijalu je navedeno da se na vjezbi implementira manji skup instrukcija: `lw`, `sw`, `add`, `sub`, `and`, `or`, `beq` i `addi`.

Iz vjezbe 2 je preuzeta osnovna ideja:

- procesor komunicira sa memorijom za instrukcije i memorijom za podatke
- projekat je podijeljen na controlpath i datapath
- datapath sadrzi PC registar, registarsku banku, immediate blok, ALU i mux logiku
- controlpath dekoduje instrukciju i daje kontrolne signale
- testbench koristi BRAM za instrukcije i podatke

## trenutna struktura projekta

```text
nms-riscv/
|-- README.md
|-- RISCV.tcl
|-- mapa_projekta.md
|-- scripts/
|   `-- run_ghdl_tests.ps1
|-- rv32i/
|   |-- TOP_RISCV.vhd
|   |-- kontrola/
|   |   |-- ctrl_decoder.vhd
|   |   |-- alu_decoder.vhd
|   |   `-- kontrola.vhd
|   |-- podaci/
|   |   |-- ALU_simple.vhd
|   |   |-- immediate.vhd
|   |   |-- podaci.vhd
|   |   `-- register_bank.vhd
|   |-- paketi/
|   |   |-- alu_ops_pkg.vhd
|   |   `-- txt_util.vhd
|   |-- testovi/
|   |   |-- ALU_zbb_tb.vhd
|   |   |-- BRAM_byte_addressable.vhd
|   |   |-- TOP_testovi.vhd
|   |   |-- assembly_code.txt
|   |   |-- assembly_code_active.txt
|   |   `-- test_programi/
|   |       |-- extended_demo.txt
|   |       |-- rv32i_regression.txt
|   |       `-- zbb_demo.txt
|   `-- vivado_projekat/
|       `-- vivado_projekat.xpr
```

## glavni fajlovi

`scripts/run_ghdl_tests.ps1`

PowerShell skripta za provjeru na ovom Windows racunaru. Kompajlira VHDL fajlove pomocu GHDL-a i pokrece ALU test, Zbb demo, prosireni demo i RV32I regresiju.

`rv32i/TOP_RISCV.vhd`

Glavni modul procesora. Povezuje dva velika dijela:

- `podaci`, odnosno datapath
- `kontrola`, odnosno controlpath

Ovaj fajl ne radi samu obradu instrukcija, nego samo spaja signale izmedju datapath-a, controlpath-a i memorija.

`rv32i/kontrola/kontrola.vhd`

Glavni fajl kontrolne logike. Iz instrukcije uzima bitna polja i povezuje:

- `ctrl_decoder`, koji prepoznaje osnovni tip instrukcije preko opcode-a
- `alu_decoder`, koji bira konkretnu ALU operaciju preko `funct3`, `funct7` i `funct12`

Ovdje se bira i sledeca vrijednost PC-a:

- normalno `PC + 4`
- branch skok
- `jal`
- `jalr`

Takodje se ovdje za store instrukcije pravi byte-enable signal:

- `sb` upisuje 1 bajt
- `sh` upisuje 2 bajta
- `sw` upisuje 4 bajta

`rv32i/kontrola/ctrl_decoder.vhd`

Dekoduje opcode i pravi osnovne kontrolne signale.

Iz originalne vjezbe su postojali signali za:

- branch
- izbor podatka iz memorije
- upis u memoriju
- izbor drugog ALU operanda
- upis u registar
- dvobitni ALU kod

U projektu je dodato:

- `alu_src_a_o`, da ALU moze kao prvi operand uzeti `rs1`, `PC` ili nulu
- `rd_src_o`, da se u registar moze upisati ALU rezultat, load podatak ili `PC + 4`
- `jump_o`, za `jal`
- `jalr_o`, za `jalr`
- opcode konstante za `lui`, `auipc`, `jal`, `jalr`, `fence`, `ecall`, `ebreak`

`rv32i/kontrola/alu_decoder.vhd`

Bira internu ALU operaciju. Originalni dekoder je razlikovao uglavnom:

- add
- sub
- or
- and
- eq za `beq`

U projektu je prosiren da prepozna:

- osnovne RV32I ALU instrukcije
- sve branch uslove preko kasnije logike u datapath-u
- RV32M instrukcije preko `funct7 = 0000001`
- Zbb instrukcije preko kombinacija `funct3`, `funct7` i `funct12`

`rv32i/podaci/podaci.vhd`

Datapath. Tu se nalaze:

- PC registar
- racunanje `PC + 4`
- racunanje branch adrese
- racunanje `jalr` adrese
- izbor prvog i drugog ALU operanda
- load prosirenje za `lb`, `lh`, `lw`, `lbu`, `lhu`
- izbor podatka koji se upisuje u odredisni registar
- povezivanje registarske banke, immediate bloka i ALU-a

U odnosu na original, dodato je:

- `pc_next_sel_i` kao 2-bitni izbor, jer vise ne postoji samo obicni PC i branch
- `jalr_next_s`, jer `jalr` ide na `rs1 + immediate`, uz postavljanje najnizeg bita na 0
- branch logika za `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
- `alu_src_a_i`, da `auipc` koristi `PC`, a `lui` nulu
- `rd_src_i`, da `jal` i `jalr` upisuju `PC + 4`
- load logika za signed i unsigned load instrukcije

`rv32i/podaci/immediate.vhd`

Izdvaja immediate polje i prosiruje ga na 32 bita.

Originalna vjezba je imala I, S i B tip. Ovdje su dodati:

- U tip, za `lui` i `auipc`
- J tip, za `jal`
- I tip se koristi i za `jalr`, load i I-type ALU instrukcije

`rv32i/podaci/ALU_simple.vhd`

ALU izvrsava operacije nad operandima.

Originalno je ALU imala osnovne operacije:

- sabiranje
- oduzimanje
- bitovski and
- bitovski or

U projektu su dodate:

- osnovne RV32I operacije: `xor`, `sll`, `srl`, `sra`, signed i unsigned poredjenje
- Zbb operacije: `andn`, `orn`, `xnor`, `clz`, `ctz`, `cpop`, `rol`, `ror`, `sext.b`, `sext.h`
- RV32M operacije: `mul`, `mulh`, `mulhsu`, `mulhu`, `div`, `divu`, `rem`, `remu`

`rv32i/podaci/register_bank.vhd`

Registarska banka sa 32 registra. Ima:

- dva porta za citanje
- jedan port za upis
- x0 registar se uvijek cita kao nula

Ovaj dio je uglavnom zadrzan iz vjezbe, samo je stil komentara i formatiranja sredjen.

`rv32i/paketi/alu_ops_pkg.vhd`

Paket sa internim kodovima ALU operacija. Ovo je mjesto gdje se svakoj ALU operaciji daje interni 5-bitni kod.

Prosiren je jer originalni ALU kodovi nisu bili dovoljni za sve nove instrukcije.

`rv32i/paketi/txt_util.vhd`

Pomocni paket za rad sa tekstom u testbenchu. Koristi se za citanje tekstualnih fajlova sa binarnim instrukcijama.

`rv32i/testovi/BRAM_byte_addressable.vhd`

Jednostavna byte-addressable memorija za simulaciju. U testbenchu se koristi kao:

- memorija za instrukcije
- memorija za podatke

`rv32i/testovi/TOP_testovi.vhd`

Glavni CPU testbench. Radi sledece:

- ucita program iz `assembly_code_active.txt`
- popuni memoriju podacima za izabrani scenario
- pokrene procesor
- prati store operacije koje procesor pravi
- poredi adrese i podatke sa ocekivanim rezultatima

Postoje tri scenarija:

- RV32I regresija
- Zbb demo
- prosireni demo sa RV32I, RV32M, Zbb, branch, jump i memory instrukcijama

`rv32i/testovi/ALU_zbb_tb.vhd`

Poseban testbench za ALU i Zbb operacije. Koristan je zato sto se nove ALU operacije mogu provjeriti bez pokretanja cijelog procesora.

`rv32i/testovi/test_programi/*.txt`

Programi u obliku 32-bitnih binarnih instrukcija:

- `rv32i_regression.txt` provjerava osnovne RV32I instrukcije
- `zbb_demo.txt` provjerava Zbb operacije
- `extended_demo.txt` provjerava siri skup instrukcija

`RISCV.tcl`

Skripta za pravljenje Vivado projekta. Dodaje sve VHDL fajlove u projekat i podesava top testbench.

## sta je preuzeto iz vjezbi

Iz vjezbe 2 je preuzet osnovni single-cycle model:

- ideja da jedna instrukcija prolazi kroz procesor u jednom taktu
- podjela na controlpath i datapath
- PC registar i `PC + 4`
- registarska banka
- immediate prosirenje
- ALU kao centralna jedinica za racunanje
- memorija za instrukcije i memorija za podatke u testbenchu
- osnovni dekoderi
- osnovni Vivado projekat i TCL nacin pravljenja projekta

Originalni podrzani skup je bio mali i sluzio je da pokaze princip:

- `lw`
- `sw`
- `add`
- `sub`
- `and`
- `or`
- `beq`
- `addi`

## sta je dodato u ovom projektu

Dodato je prosirenje tako da projekat podrzava mnogo veci skup instrukcija.

Dodate RV32I instrukcije i dijelovi koji nisu bili pokriveni osnovnom vjezbom:

- `lui`
- `auipc`
- `jal`
- `jalr`
- `bne`
- `blt`
- `bge`
- `bltu`
- `bgeu`
- `lb`
- `lh`
- `lbu`
- `lhu`
- `sb`
- `sh`
- `slti`
- `sltiu`
- `xori`
- `ori`
- `andi`
- `slli`
- `srli`
- `srai`
- `sll`
- `slt`
- `sltu`
- `xor`
- `srl`
- `sra`
- `fence`
- `ecall`
- `ebreak`

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
- `sext.b`
- `sext.h`

## zasto je dodato bas ovako

Projekat je single-cycle, pa je najjednostavnije da se nove instrukcije dodaju kroz postojece blokove:

- ako instrukcija samo mijenja kontrolu toka, dodaje se u `kontrola.vhd` i `podaci.vhd`
- ako instrukcija mijenja nacin upisa u registar, dodaje se preko `rd_src_o` i mux-a u `podaci.vhd`
- ako instrukcija koristi novi immediate format, dodaje se u `immediate.vhd`
- ako instrukcija predstavlja novu racunsku operaciju, dodaje se u `alu_decoder.vhd`, `alu_ops_pkg.vhd` i `ALU_simple.vhd`
- ako instrukcija koristi drugaciji load/store format, dodaje se u load prosirenje i byte-enable logiku

Ovim se ne uvodi nova velika arhitektura, nego se postojece rjesenje sa vjezbi samo prosiruje.

## gdje su dodate instrukcije

### RV32I kontrolne instrukcije

`jal`, `jalr`, branch instrukcije i PC izbor nalaze se u:

- `rv32i/kontrola/ctrl_decoder.vhd`
- `rv32i/kontrola/kontrola.vhd`
- `rv32i/podaci/podaci.vhd`
- `rv32i/podaci/immediate.vhd`

`jal` koristi J immediate, upisuje `PC + 4` u `rd` i mijenja PC na `PC + immediate`.

`jalr` koristi I immediate, upisuje `PC + 4` u `rd` i mijenja PC na `rs1 + immediate`, pri cemu se najnizi bit postavlja na 0.

Branch instrukcije koriste B immediate. U `podaci.vhd` se porede `rs1` i `rs2`, a `kontrola.vhd` na osnovu tog uslova bira sledeci PC.

### load i store instrukcije

Load instrukcije su u:

- `rv32i/kontrola/ctrl_decoder.vhd`
- `rv32i/podaci/podaci.vhd`

`lb` i `lh` rade signed prosirenje, a `lbu` i `lhu` unsigned prosirenje. `lw` uzima cijelu rijec.

Store instrukcije su u:

- `rv32i/kontrola/ctrl_decoder.vhd`
- `rv32i/kontrola/kontrola.vhd`

`sb`, `sh` i `sw` koriste isti osnovni store tok, ali se razlikuje byte-enable signal za memoriju.

### ALU instrukcije

ALU instrukcije su rasporedjene kroz:

- `rv32i/kontrola/alu_decoder.vhd`, gdje se prepoznaje instrukcija
- `rv32i/paketi/alu_ops_pkg.vhd`, gdje se nalazi interni kod operacije
- `rv32i/podaci/ALU_simple.vhd`, gdje se operacija stvarno racuna

Na primjer:

- `xor` se prepoznaje preko `funct3 = 100`
- `sll` preko `funct3 = 001`
- `srl` i `sra` preko `funct3 = 101` i `funct7`
- `slt` i `sltu` preko `funct3 = 010` i `011`

### RV32M instrukcije

RV32M instrukcije se prepoznaju u `alu_decoder.vhd` kada je:

- `alu_2bit_op_i = "10"`
- `funct7_i = "0000001"`

Tada `funct3` bira tacnu operaciju:

- `000` -> `mul`
- `001` -> `mulh`
- `010` -> `mulhsu`
- `011` -> `mulhu`
- `100` -> `div`
- `101` -> `divu`
- `110` -> `rem`
- `111` -> `remu`

Sama matematika je u `ALU_simple.vhd`.

### Zbb instrukcije

Zbb instrukcije su dodate zato sto su dobar primjer prosirenja ALU-a bez mijenjanja cijelog procesora. One uglavnom rade bit-manipulation operacije nad registrima.

U projektu su:

- `andn`: `rs1 and not rs2`
- `orn`: `rs1 or not rs2`
- `xnor`: `not(rs1 xor rs2)`
- `clz`: broj vodecih nula
- `ctz`: broj nula sa desne strane
- `cpop`: broj jedinica
- `rol`: rotacija ulijevo
- `ror`: rotacija udesno
- `sext.b`: sign extension bajta
- `sext.h`: sign extension polurijeci

`andn`, `orn`, `xnor`, `rol` i `ror` koriste R-type oblik instrukcije.

`clz`, `ctz`, `cpop`, `sext.b` i `sext.h` koriste I-type oblik i zato se u dekoderu koristi `funct12_i`.

## tok jedne instrukcije

1. PC iz `podaci.vhd` daje adresu memoriji za instrukcije.
2. Instrukcija dolazi u `instruction_s`.
3. `kontrola.vhd` salje opcode u `ctrl_decoder.vhd`.
4. `ctrl_decoder.vhd` pravi osnovne signale: upis u registar, izbor operanda, load/store, jump i slicno.
5. `alu_decoder.vhd` cita `funct3`, `funct7` i `funct12` i bira ALU operaciju.
6. `immediate.vhd` izdvaja immediate ako ga instrukcija ima.
7. `podaci.vhd` bira operande i poziva ALU.
8. `ALU_simple.vhd` racuna rezultat.
9. Rezultat se upisuje u registar, memoriju ili se koristi za promjenu PC-a.

## kratko poredjenje sa originalom

| dio | vjezba 2 | ovaj projekat |
| --- | --- | --- |
| osnovna arhitektura | single-cycle | single-cycle |
| podjela | controlpath + datapath | kontrola + podaci |
| osnovni skup | `lw`, `sw`, `add`, `sub`, `and`, `or`, `beq`, `addi` | kompletan dokumentovani RV32I skup u projektu + RV32M + Zbb podskup |
| PC izbor | `PC + 4` ili branch | `PC + 4`, branch, `jal`, `jalr` |
| immediate | I, S, B | I, S, B, U, J |
| ALU | add, sub, and, or | RV32I ALU, RV32M i Zbb operacije |
| load/store | `lw`, `sw` | `lb`, `lh`, `lw`, `lbu`, `lhu`, `sb`, `sh`, `sw` |
| testbench | osnovni program | vise scenarija i provjera ocekivanih store rezultata |

## sustina projekta

Sustina projekta je da se polazni single-cycle RISC-V procesor iz vjezbi prosiri bez nepotrebnog komplikovanja. Zadrzana je ista skolska organizacija, ali je dodato dovoljno dekodiranja, ALU operacija, immediate formata i testova da procesor podrzi mnogo siri skup instrukcija.

Drugim rijecima, projekat nije pravljen kao nova arhitektura od nule, nego kao razumljivo prosirenje postojeceg edukativnog procesora.
